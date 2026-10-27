"""Exercise the complete checker CLI with controlled process and HTTP boundaries."""

import fcntl
import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

CHECKER = Path(__file__).with_name("check.py")
REVISION = "a" * 40
NEW_REVISION = "b" * 40
RELEASES = "https://github.com/example/agent/releases"
TAG_URL = f"{RELEASES}/tag/v1.10.0"
FEED = f"""<feed xmlns="http://www.w3.org/2005/Atom"><entry>
<link href="{TAG_URL}"/><content type="html">
&lt;h2&gt;Added&lt;/h2&gt;&lt;ul&gt;&lt;li&gt;Useful feature &amp;lt;safe&amp;gt;&lt;/li&gt;&lt;/ul&gt;
</content></entry></feed>"""
GROK_CHANGELOG = "https://x.ai/changelog/build"
GROK_RSS = f"{GROK_CHANGELOG}/rss.xml"
GROK_FEED = f"""<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom"><channel>
<title>Grok Build Changelog</title><link>{GROK_CHANGELOG}</link>
<item><title>Grok Build 1.0.70</title>
<link>{GROK_CHANGELOG}#v1.0.70-2026-10-23</link>
<description>&lt;ul&gt;&lt;li&gt;Newer release only&lt;/li&gt;&lt;/ul&gt;</description></item>
<item><title>Grok Build 1.0.69</title>
<link>{GROK_CHANGELOG}#v1.0.69-2026-10-23</link>
<description>&lt;ul&gt;&lt;li&gt;Dashboard directory grouping now shows a header
with the folder path and agent count&lt;/li&gt;&lt;/ul&gt;</description></item>
</channel></rss>"""

COMMAND = """import json, os, pathlib, subprocess, sys
name = pathlib.Path(sys.argv[0]).name
with open(os.environ['EVENTS'], 'a') as log:
    log.write(json.dumps([name, *sys.argv[1:]]) + '\\n')
fixture = json.loads(os.environ['FIXTURE'])
if name == 'git':
    print(fixture['revision'] + '\\trefs/heads/main')
elif name == 'nix':
    if 'flake' in fixture:
        arguments = sys.argv[1:]
        arguments[-1] = fixture['flake']
        sys.exit(subprocess.run([fixture['nix'], *arguments], check=False).returncode)
    print(json.dumps(fixture['available']))
print(fixture.get('error', ''), file=sys.stderr)
sys.exit(fixture.get(name + '_status', 0))
"""

RUNNER = """import io, json, os, runpy, sys, urllib.error, urllib.request
from unittest.mock import patch
fixture = json.loads(os.environ['FIXTURE'])
def fetch(request, **kwargs):
    url = request.full_url
    with open(os.environ['EVENTS'], 'a') as log:
        log.write(json.dumps(['http', url]) + '\\n')
    if url in fixture.get('http_errors', {}):
        raise urllib.error.HTTPError(url, fixture['http_errors'][url], 'HTTP failure', {}, None)
    if url not in fixture['http']:
        raise urllib.error.URLError('unavailable: ' + url)
    return io.BytesIO(fixture['http'][url].encode())
sys.argv = sys.argv[1:]
with patch.object(urllib.request, 'urlopen', fetch):
    runpy.run_path(sys.argv[0], run_name='__main__')
"""


class CheckerWorkflow(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name).resolve()
        self.events = self.root / "events.jsonl"
        self.manifest = self.root / "installed.json"
        self.manifest.write_text(
            json.dumps(
                {
                    "revision": REVISION,
                    "system": "aarch64-darwin",
                    "packages": {"agent": {"version": "1.9.0"}},
                }
            )
        )
        self.runner = self.root / "runner.py"
        self.runner.write_text(RUNNER)
        for command in ["git", "nix", "terminal-notifier"]:
            executable = self.root / command
            executable.write_text(f"#!{sys.executable}\n{COMMAND}")
            executable.chmod(0o755)
        self.fixture = {
            "revision": NEW_REVISION,
            "available": {
                "agent": {
                    "version": "1.10.0",
                    "newer": True,
                    "changelog": RELEASES,
                }
            },
            "http": {f"{RELEASES}.atom": FEED},
        }

    def invoke(self, *arguments):
        result = subprocess.run(
            [
                sys.executable,
                str(self.runner),
                str(CHECKER),
                "--manifest",
                str(self.manifest),
                "--expression",
                str(CHECKER.with_name("latest.nix")),
                "--state-dir",
                str(self.root),
                *arguments,
            ],
            env={
                **os.environ,
                "PATH": f"{self.root}{os.pathsep}{os.environ['PATH']}",
                "FIXTURE": json.dumps(self.fixture),
                "EVENTS": str(self.events),
            },
            capture_output=True,
            text=True,
            timeout=15,
            check=False,
        )
        events = (
            [json.loads(line) for line in self.events.read_text().splitlines()]
            if self.events.exists()
            else []
        )
        return result, events

    def test_unchanged_revision_skips_evaluation_and_release_requests(self):
        self.fixture["revision"] = REVISION
        result, events = self.invoke()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("没有更新", result.stdout)
        self.assertEqual([event[0] for event in events], ["git", "terminal-notifier"])

    def test_unrelated_upstream_changes_skip_release_requests(self):
        self.fixture["available"]["agent"]["newer"] = False
        result, events = self.invoke()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("没有更新", result.stdout)
        self.assertEqual(
            [event[0] for event in events], ["git", "nix", "terminal-notifier"]
        )

    def test_updates_include_notes_and_clickable_escaped_report(self):
        result, events = self.invoke()
        self.assertEqual(result.returncode, 0, result.stderr)
        notification = events[-1]
        self.assertEqual(notification[0], "terminal-notifier")
        self.assertIn(
            "1.9.0 → 1.10.0", notification[notification.index("-message") + 1]
        )
        self.assertIn("Useful feature", result.stdout)
        self.assertEqual(notification[-1], (self.root / "latest.html").as_uri())
        report = (self.root / "latest.html").read_text()
        self.assertIn("Useful feature &lt;safe&gt;", report)
        self.assertIn(TAG_URL, report)

    def test_tag_outside_feed_uses_release_page(self):
        self.fixture["available"]["agent"]["changelog"] = f"{RELEASES}/tag/pkg%2F1.10.0"
        url = f"{RELEASES}/tag/pkg%2F1.10.0"
        self.fixture["http"][url] = (
            '<div>Navigation</div><div class="markdown-body">'
            "<h2>Fixed</h2><ul><li>Important fix</li></ul></div><div>Footer</div>"
        )
        result, events = self.invoke()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Important fix", result.stdout)
        self.assertIn(["http", url], events)
        report = (self.root / "latest.html").read_text()
        self.assertNotIn("Navigation", report)
        self.assertNotIn("Footer", report)

    def test_check_failure_never_reports_no_updates(self):
        for command in ["git", "nix"]:
            with self.subTest(command=command):
                self.fixture[f"{command}_status"] = 1
                self.fixture["error"] = "network unavailable"
                result, events = self.invoke()
                self.assertEqual(result.returncode, 1)
                self.assertIn("检查失败", result.stdout)
                self.assertNotIn("没有更新", result.stdout)
                self.assertEqual(events[-1][0], "terminal-notifier")
                self.assertIn(
                    "network unavailable", (self.root / "latest.html").read_text()
                )
                del self.fixture[f"{command}_status"]

    def test_release_failure_preserves_update_notification(self):
        self.fixture["http"] = {}
        result, _ = self.invoke()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("1 个包有更新（部分说明不可用）", result.stdout)
        self.assertIn("1.9.0 → 1.10.0", result.stdout)
        self.assertIn("Release notes 获取失败", (self.root / "latest.html").read_text())

    def configure_grok(self):
        installed = json.loads(self.manifest.read_text())
        installed["packages"] = {"grok": {"version": "1.0.68"}}
        self.manifest.write_text(json.dumps(installed))
        self.fixture["available"] = {
            "grok": {"version": "1.0.69", "newer": True, "changelog": "https://x.ai"}
        }
        self.fixture["http"] = {GROK_RSS: GROK_FEED}

    def test_grok_uses_official_rss_and_matches_the_packaged_version(self):
        self.configure_grok()
        result, events = self.invoke()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("grok: 1.0.68 → 1.0.69", result.stdout)
        self.assertIn("Dashboard directory grouping", result.stdout)
        self.assertNotIn("部分说明不可用", result.stdout)
        self.assertEqual(
            [event for event in events if event[0] == "http"], [["http", GROK_RSS]]
        )
        report = (self.root / "latest.html").read_text()
        self.assertIn(f"{GROK_CHANGELOG}#v1.0.69-2026-10-23", report)
        self.assertNotIn("Newer release only", report)

    def test_grok_missing_version_or_invalid_feed_preserves_update(self):
        for feed in [
            GROK_FEED.replace("1.0.69", "1.0.67"),
            "<html>Blocked</html>",
            "invalid XML",
        ]:
            with self.subTest(feed=feed):
                self.configure_grok()
                self.fixture["http"][GROK_RSS] = feed
                result, _ = self.invoke()
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn("1 个包有更新（部分说明不可用）", result.stdout)
                self.assertIn("grok: 1.0.68 → 1.0.69", result.stdout)
                report = (self.root / "latest.html").read_text()
                self.assertIn(GROK_CHANGELOG, report)
                self.assertNotIn("Newer release only", report)

    def test_grok_http_failure_preserves_update_and_official_link(self):
        self.configure_grok()
        self.fixture["http_errors"] = {GROK_RSS: 403}
        result, _ = self.invoke()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("1 个包有更新（部分说明不可用）", result.stdout)
        self.assertIn("grok: 1.0.68 → 1.0.69", result.stdout)
        self.assertIn(GROK_CHANGELOG, (self.root / "latest.html").read_text())

    def test_no_grok_update_skips_the_changelog(self):
        self.configure_grok()
        self.fixture["available"]["grok"]["newer"] = False
        result, events = self.invoke()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("没有更新", result.stdout)
        self.assertNotIn("http", [event[0] for event in events])

    def test_no_notify_still_generates_report(self):
        result, events = self.invoke("--no-notify")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue((self.root / "latest.html").exists())
        self.assertNotIn("terminal-notifier", [event[0] for event in events])

    def test_notification_failure_is_observable(self):
        self.fixture["terminal-notifier_status"] = 1
        result, _ = self.invoke()
        self.assertEqual(result.returncode, 1)
        self.assertIn("系统通知发送失败", result.stderr)
        self.assertTrue((self.root / "latest.html").exists())

    def test_nix_evaluates_numeric_versions_and_ignores_downgrades(self):
        self.fixture["nix"] = shutil.which("nix")
        self.assertIsNotNone(
            self.fixture["nix"], "Nix is required for this workflow test"
        )
        for version in ["1.10.0", "1.9.0", "1.8.0"]:
            with self.subTest(version=version):
                flake = self.root / version
                flake.mkdir()
                (flake / "flake.nix").write_text(
                    "{ outputs = _: { packages.aarch64-darwin.agent = { "
                    f'version = "{version}"; meta.changelog = "{RELEASES}"; '
                    "}; }; }"
                )
                self.fixture["flake"] = f"path:{flake}"
                result, _ = self.invoke()
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                expected = "1 个包有更新" if version == "1.10.0" else "没有更新"
                self.assertIn(expected, result.stdout)

    def test_concurrent_check_does_not_duplicate_work(self):
        with (self.root / "check.lock").open("w") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            result, events = self.invoke()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(events, [])


if __name__ == "__main__":
    unittest.main()
