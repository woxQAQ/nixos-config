import subprocess
import sys

import gi

gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib


def main():
    settings = Gio.Settings.new("org.gnome.desktop.interface")
    loop = GLib.MainLoop()
    failed = False

    def update(settings, _key):
        nonlocal failed
        mode = (
            "dark" if settings.get_string("color-scheme") == "prefer-dark" else "light"
        )
        result = subprocess.run([sys.argv[1], mode], check=False)
        if result.returncode:
            failed = True
            loop.quit()

    # Subscribe before reading the initial value so startup cannot lose a change.
    settings.connect("changed::color-scheme", update)
    update(settings, "color-scheme")
    if not failed:
        loop.run()
    return int(failed)


if __name__ == "__main__":
    sys.exit(main())
