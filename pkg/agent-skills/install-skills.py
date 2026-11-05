"""Install each source's skills under their published frontmatter names."""

import re
import shutil
import sys
from pathlib import Path

import yaml


def install(destination, sources):
    for source in sources:
        namespace, root = source.split("=", 1)
        manifests = sorted(Path(root).rglob("SKILL.md"))
        if not manifests:
            raise ValueError(f"No skills found in {root}")
        for manifest in manifests:
            lines = manifest.read_text().splitlines()
            if not lines or lines[0] != "---":
                raise ValueError(f"Missing frontmatter: {manifest}")
            end = lines.index("---", 1)
            metadata = yaml.safe_load("\n".join(lines[1:end]))
            name = metadata.get("name")
            if not isinstance(name, str) or not re.fullmatch(
                r"[a-z0-9]+(?:-[a-z0-9]+)*", name
            ):
                raise ValueError(f"Invalid skill name {name!r}: {manifest}")
            target = destination / namespace / name
            # copytree rejects duplicate names within the same source.
            shutil.copytree(manifest.parent, target)
            print(f"Installed {namespace}/{name}")


if __name__ == "__main__":
    install(Path(sys.argv[1]), sys.argv[2:])
