"""Check the activated llm-agents package set and deliver one macOS notification."""

import argparse
import datetime
import fcntl
import html
import json
import re
import subprocess
import sys
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from html.parser import HTMLParser
from pathlib import Path

UPSTREAM = "https://github.com/numtide/llm-agents.nix"
GROK_CHANGELOG = "https://x.ai/changelog/build"
ATOM = {"a": "http://www.w3.org/2005/Atom"}


class ReleaseText(HTMLParser):
    """Read Atom HTML or the release body on a GitHub tag page as plain text."""

    def __init__(self, page=False):
        super().__init__()
        self.page = page
        self.depth = 0
        self.parts = []

    def handle_starttag(self, tag, attrs):
        if self.page:
            if tag == "div" and (
                self.depth or "markdown-body" in dict(attrs).get("class", "").split()
            ):
                self.depth += 1
            if not self.depth:
                return
        if tag in {"p", "li", "br", "div", "pre", "h1", "h2", "h3", "h4"}:
            self.parts.append("\n")
        if tag == "li":
            self.parts.append("• ")

    def handle_endtag(self, tag):
        if self.page and not self.depth:
            return
        if tag in {"p", "li", "div", "pre", "h1", "h2", "h3", "h4"}:
            self.parts.append("\n")
        if self.page and tag == "div":
            self.depth -= 1

    def handle_data(self, data):
        if not self.page or self.depth:
            self.parts.append(data)

    def text(self):
        return "\n".join(
            line.strip() for line in "".join(self.parts).splitlines() if line.strip()
        )


def run(arguments, timeout=30):
    result = subprocess.run(
        arguments, text=True, capture_output=True, timeout=timeout, check=False
    )
    if result.returncode:
        raise RuntimeError(
            f"{arguments[0]} 退出码 {result.returncode}: {result.stderr.strip()[-2000:]}"
        )
    return result.stdout


def fetch(url):
    request = urllib.request.Request(
        url, headers={"User-Agent": "llm-agents-update-notifier"}
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        return response.read().decode("utf-8")


def grok_release_notes(version):
    try:
        feed = ET.fromstring(fetch(f"{GROK_CHANGELOG}/rss.xml"))
        if feed.findtext("channel/link") != GROK_CHANGELOG:
            raise ValueError("返回的 RSS 不是 Grok Build changelog")
        for entry in feed.findall("channel/item"):
            if entry.findtext("title", "").strip() != f"Grok Build {version}":
                continue
            parser = ReleaseText()
            parser.feed(entry.findtext("description", ""))
            notes = parser.text()
            if not notes:
                raise ValueError(f"Grok Build {version} 的更新说明为空")
            url = entry.findtext("link", GROK_CHANGELOG)
            if not url.startswith(f"{GROK_CHANGELOG}#"):
                url = GROK_CHANGELOG
            return url, notes, True
        raise ValueError(f"官方 changelog 中没有 Grok Build {version} 的更新说明")
    except (OSError, ValueError, ET.ParseError) as error:
        return GROK_CHANGELOG, f"Release notes 获取失败：{error}", False


def release_notes(name, package):
    if name == "grok":
        return grok_release_notes(package["version"])
    # Use the packaging metadata so repository moves and unusual tags follow upstream.
    match = re.fullmatch(
        r"https://github\.com/([^/]+/[^/]+)/releases(?:/tag/(.+))?/?",
        package["changelog"],
    )
    if not match:
        return (
            package["changelog"],
            "llm-agents 未提供可读取的 GitHub release notes；请查看上游链接。",
            False,
        )
    repository, tag = match.groups()
    tag = urllib.parse.unquote(tag) if tag else f"v{package['version']}"
    url = f"https://github.com/{repository}/releases/tag/{urllib.parse.quote(tag, safe='')}"
    feed_error = ""
    try:
        feed = ET.fromstring(fetch(f"https://github.com/{repository}/releases.atom"))
        for entry in feed.findall("a:entry", ATOM):
            link = entry.find("a:link", ATOM)
            if link is None:
                continue
            if urllib.parse.unquote(link.get("href", "")) == urllib.parse.unquote(url):
                parser = ReleaseText()
                parser.feed(entry.findtext("a:content", "", ATOM))
                if parser.text():
                    return url, parser.text(), True
    except (OSError, ValueError, ET.ParseError) as error:
        feed_error = f"Atom: {error}; "

    # Busy repositories can push the stable tag out of the Atom feed with prereleases.
    try:
        parser = ReleaseText(page=True)
        parser.feed(fetch(url))
        if parser.text():
            return url, parser.text(), True
        raise ValueError("release 页面没有说明正文")
    except (OSError, ValueError) as error:
        return url, f"Release notes 获取失败：{feed_error}{error}", False


def check_versions(args, installed):
    head = run(["git", "ls-remote", f"{UPSTREAM}.git", "refs/heads/main"])
    revision = head.split()[0] if head.strip() else ""
    if not re.fullmatch(r"[0-9a-f]{40}", revision):
        raise ValueError("无法读取 llm-agents main 提交")
    if revision == installed["revision"]:
        return revision, {}
    upstream = f"git+{UPSTREAM}?ref=main&rev={revision}&shallow=1"
    available = json.loads(
        run(
            [
                "nix",
                "eval",
                "--impure",
                "--json",
                "--no-write-lock-file",
                "--option",
                "accept-flake-config",
                "false",
                "--file",
                str(args.expression),
                "versions",
                "--argstr",
                "manifest",
                str(args.manifest),
                "--argstr",
                "upstream",
                upstream,
            ],
            timeout=300,
        )
    )
    if available.keys() != installed["packages"].keys():
        raise ValueError("上游检查结果与已安装包清单不一致")
    updates = {}
    for name, package in available.items():
        if not isinstance(package["newer"], bool) or not package["version"]:
            raise ValueError(f"无效的上游版本：{name}")
        if package["newer"]:
            updates[name] = package
    return revision, updates


def report(path, title, summary, sections, revision):
    checked_at = datetime.datetime.now().astimezone().isoformat(timespec="seconds")
    content = [
        '<!doctype html><html lang="zh-CN"><meta charset="utf-8">',
        f"<title>{html.escape(title)}</title>",
        (
            "<style>body{max-width:900px;margin:40px auto;padding:0 20px;"
            "font:16px/1.6 system-ui}pre{white-space:pre-wrap;font:inherit}"
            "h2{margin-top:2em}a{overflow-wrap:anywhere}</style>"
        ),
        f"<h1>{html.escape(title)}</h1><p>{html.escape(checked_at)}</p>",
        f"<p>{html.escape(summary)}</p>",
    ]
    if revision:
        content.append(
            f'<p>llm-agents: <a href="{UPSTREAM}/commit/{revision}">{revision[:12]}</a></p>'
        )
    for heading, url, body in sections:
        content.append(f"<h2>{html.escape(heading)}</h2>")
        if urllib.parse.urlsplit(url).scheme in {"http", "https"}:
            content.append(
                f'<p><a href="{html.escape(url, quote=True)}">上游 release notes</a></p>'
            )
        content.append(f"<pre>{html.escape(body)}</pre>")
    content.append("</html>")
    temporary = path.with_suffix(".tmp")
    temporary.write_text("\n".join(content), encoding="utf-8")
    temporary.replace(path)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--expression", type=Path, required=True)
    parser.add_argument("--state-dir", type=Path, required=True)
    parser.add_argument(
        "--no-notify", action="store_true", help="只检查并生成报告，不发送系统通知"
    )
    args = parser.parse_args()
    args.state_dir.mkdir(parents=True, exist_ok=True)
    with (args.state_dir / "check.lock").open("w") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            print("已有 llm-agents 检查正在运行。")
            return 0
        return check(args)


def check(args):
    revision = ""
    sections = []
    status = 0
    try:
        installed = json.loads(args.manifest.read_text(encoding="utf-8"))
        revision, updates = check_versions(args, installed)
        if not updates:
            title = "llm-agents：没有更新"
            summary = f"已检查 {len(installed['packages'])} 个已安装包，没有更高版本。"
            sections = [
                (name, "", f"已安装 {package['version']}")
                for name, package in installed["packages"].items()
            ]
        else:
            title = f"llm-agents：{len(updates)} 个包有更新"
            lines = []
            incomplete = []
            for name, package in updates.items():
                heading = f"{name}: {installed['packages'][name]['version']} → {package['version']}"
                url, notes, complete = release_notes(name, package)
                sections.append((heading, url, notes))
                # Prefer a release item over a section heading for the banner preview.
                preview = next(
                    (line for line in notes.splitlines() if line.startswith("• ")),
                    notes.splitlines()[0] if notes else "无说明正文",
                )
                lines.append(f"{heading}\n{preview[:100]}")
                if not complete:
                    incomplete.append(name)
            summary = "\n".join(lines)
            if incomplete:
                title += "（部分说明不可用）"
    except (
        OSError,
        ValueError,
        KeyError,
        RuntimeError,
        subprocess.TimeoutExpired,
    ) as error:
        title = "llm-agents：检查失败"
        summary = "未能完成版本检查，点击通知查看错误。"
        sections = [("错误", "", str(error))]
        status = 1

    report_path = (args.state_dir / "latest.html").resolve()
    report(report_path, title, summary, sections, revision)
    print(
        f"{datetime.datetime.now().astimezone().isoformat(timespec='seconds')} {title}"
    )
    print(summary)
    print(f"报告：{report_path}", flush=True)
    if not args.no_notify:
        message = summary if len(summary) <= 350 else summary[:349] + "…"
        try:
            run(
                [
                    "terminal-notifier",
                    "-title",
                    title,
                    "-subtitle",
                    "点击查看完整检查报告与 release notes",
                    "-message",
                    message,
                    "-group",
                    "llm-agents-update-notifier",
                    "-open",
                    report_path.as_uri(),
                ]
            )
        except (OSError, RuntimeError, subprocess.TimeoutExpired) as error:
            print(f"系统通知发送失败：{error}", file=sys.stderr)
            return 1
    return status


if __name__ == "__main__":
    sys.exit(main())
