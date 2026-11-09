"""Replace DBeaver's Maven driver libraries with Nix-provided JDBC JARs."""

import json
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from zipfile import ZipFile

plugins_dir = Path(sys.argv[1])
libraries_dir = Path(sys.argv[2])
packages = json.loads(Path(sys.argv[3]).read_text())
artifacts = {}
matched_packages = set()

for package in packages:
    jars = sorted(Path(package["directory"]).glob("*.jar"))
    if not jars:
        raise SystemExit(f"No share/java JARs found for {package['name']}")
    for jar in jars:
        # Symlinks keep dependencies visible to Nix's scanner outside ZIP archives.
        local_jar = libraries_dir / package["name"] / jar.name
        local_jar.parent.mkdir(parents=True, exist_ok=True)
        local_jar.symlink_to(jar)
        with ZipFile(jar) as archive:
            for entry in archive.namelist():
                parts = entry.split("/")
                if (
                    len(parts) == 5
                    and parts[:2] == ["META-INF", "maven"]
                    and parts[4] == "pom.properties"
                ):
                    coordinates = (parts[2], parts[3])
                    if coordinates in artifacts:
                        raise SystemExit(f"Duplicate Maven artifact: {coordinates}")
                    artifacts[coordinates] = (local_jar, package["name"])

for plugin_jar in sorted(plugins_dir.glob("*.jar")):
    with ZipFile(plugin_jar) as archive:
        if "plugin.xml" not in archive.namelist():
            continue
        root = ET.fromstring(archive.read("plugin.xml"))
        changed = False
        for driver in root.findall(".//driver"):
            bundled_alternatives = set()
            for library in driver.findall("file[@type='jar']"):
                path = library.get("path", "")
                if not path.startswith("maven:/"):
                    continue
                coordinates = tuple(path.removeprefix("maven:/").split(":")[:2])
                if coordinates not in artifacts:
                    continue
                local_jar, package_name = artifacts[coordinates]
                bundle = library.get("bundle", "")
                if bundle.startswith("!"):
                    bundled_alternatives.add(bundle[1:])
                library.attrib = {"type": "jar", "path": str(local_jar)}
                matched_packages.add(package_name)
                changed = True
            for library in driver.findall("file[@type='jar']"):
                if library.get("bundle") in bundled_alternatives:
                    driver.remove(library)
        if not changed:
            continue

        updated_xml = ET.tostring(root, encoding="utf-8", xml_declaration=True)
        patched_jar = plugin_jar.with_suffix(".patched")
        with ZipFile(patched_jar, "w") as patched:
            for entry in archive.infolist():
                contents = (
                    updated_xml
                    if entry.filename == "plugin.xml"
                    else archive.read(entry)
                )
                patched.writestr(entry, contents)
    patched_jar.replace(plugin_jar)

unmatched = {package["name"] for package in packages} - matched_packages
if unmatched:
    raise SystemExit(
        f"No DBeaver Maven driver libraries matched: {', '.join(sorted(unmatched))}"
    )
