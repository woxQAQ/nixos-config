import sys
import re

def main():
    lines = []
    print("Reading lines from standard input. Press Ctrl+D (or Ctrl+Z on Windows) to end input.")
    for line in sys.stdin:
        lines.append(line)
    for line in lines:
        if line.strip() == "":
            continue
        if line.startswith("#"):
            continue
        line = re.sub(r'#.*$', '', line)  # Remove comments
        line = line.strip()  # Strip leading and trailing whitespace
        line = line.removeprefix("\"").removesuffix("\n").removesuffix("\"")
        if line == "":
            continue
        line = "windowrulev2 = " + line  
        print(line)


if __name__ == "__main__":
    main()