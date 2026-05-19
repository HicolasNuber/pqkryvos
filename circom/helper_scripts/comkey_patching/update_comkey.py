### Patch comkey in circom file from JSON file

import json
import re
import argparse
import sys


def extract_param(text, name):
    pattern = rf"var\s+{name}\s*=\s*(\d+)\s*;"
    match = re.search(pattern, text)
    if not match:
        raise ValueError(f"Could not find 'var {name} = ...;' in circuit")
    return int(match.group(1))


def main():
    parser = argparse.ArgumentParser(description="Patch Circom comkey from JSON")
    parser.add_argument("json_file", help="Path to comkey.json")
    parser.add_argument("circom_in", help="Path to unpatched circom file")
    parser.add_argument(
        "--out",
        help="Output circom file (default: overwrite input)",
        default=None,
    )

    args = parser.parse_args()

    # Read circuit
    with open(args.circom_in, "r") as f:
        circom_text = f.read()

    # Extract parameters
    N = extract_param(circom_text, "N")
    n = extract_param(circom_text, "n")
    k = extract_param(circom_text, "k")

    # Load JSON
    with open(args.json_file, "r") as f:
        data = json.load(f)

    if "comkey" not in data:
        raise ValueError("JSON must contain top-level key 'comkey'")

    comkey = data["comkey"]

    # Dimension checks
    if len(comkey) != n + 1:
        raise ValueError(f"JSON first dimension {len(comkey)} != n+1 ({n+1})")

    if any(len(comkey[i]) != k for i in range(n + 1)):
        raise ValueError("JSON second dimension does not match k")

    if any(len(comkey[i][j]) != N for i in range(n + 1) for j in range(k)):
        raise ValueError("JSON third dimension does not match N")

    # Generate explicit assignments
    lines = []
    for i in range(n + 1):
        for j in range(k):
            for s in range(N):
                value = comkey[i][j][s]
                lines.append(f"comkey[{i}][{j}][{s}] = {value};")

    generated_code = "\n".join(lines)

    # Regex to locate placeholder triple loop
    loop_pattern = (
        r"for\s*\(var\s+i=0;.*?\{\s*"
        r"for\s*\(var\s+j=0;.*?\{\s*"
        r"for\s*\(var\s+s=0;.*?\{\s*"
        r"comkey\[i\]\[j\]\[s\]\s*=\s*2;.*?"
        r"\}\s*\}\s*\}"
    )

    patched_text = re.sub(loop_pattern, generated_code, circom_text, flags=re.DOTALL)

    if patched_text == circom_text:
        raise RuntimeError("Failed to locate placeholder comkey loop block.")

    output_file = args.out if args.out else args.circom_in

    with open(output_file, "w") as f:
        f.write(patched_text)

    print(f"Patched circuit written to {output_file}")


if __name__ == "__main__":
    main()