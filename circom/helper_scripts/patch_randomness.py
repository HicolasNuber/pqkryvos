#!/usr/bin/env python3

import argparse
import json
import secrets
import sys
from pathlib import Path

# Supported primes
GOLDILOCKS_PRIME = 18446744069414584321
BN254_PRIME = 21888242871839275222246405745257275088548364400416034343698204186575808495617


def parse_prime(prime_arg: str) -> int:
    if prime_arg.lower() == "goldilocks":
        return GOLDILOCKS_PRIME
    elif prime_arg.lower() == "bn254":
        return BN254_PRIME
    else:
        raise ValueError("Prime must be either 'goldilocks' or 'bn254'.")


def random_field_element(p: int) -> int:
    # Cryptographically secure random choice from {0, 1, p-1}
    choice = secrets.randbelow(3)
    if choice == 0:
        return 0
    elif choice == 1:
        return 1
    else:
        return p - 1


def patch_randomness_structure(obj, p: int):
    if isinstance(obj, list):
        return [patch_randomness_structure(x, p) for x in obj]
    else:
        # Replace leaf element regardless of original value
        return random_field_element(p)


def main():
    parser = argparse.ArgumentParser(
        description="Patch the 'randomness' field in a Circom input JSON."
    )
    parser.add_argument("input", help="Path to input JSON file")
    parser.add_argument(
        "--prime",
        default="goldilocks",
        help="Prime modulus: 'goldilocks' (default) or 'bn254'",
    )
    parser.add_argument(
        "--output",
        help="Output file path (default: overwrite input file)",
    )

    args = parser.parse_args()

    input_path = Path(args.input)
    output_path = Path(args.output) if args.output else input_path

    try:
        p = parse_prime(args.prime)
    except ValueError as e:
        print(f"Error: {e}")
        sys.exit(1)

    if not input_path.exists():
        print(f"Error: Input file '{input_path}' not found.")
        sys.exit(1)

    with open(input_path, "r") as f:
        data = json.load(f)

    if "randomness" not in data:
        print("No field 'randomness' found in input JSON.")
        sys.exit(1)

    data["randomness"] = patch_randomness_structure(data["randomness"], p)

    with open(output_path, "w") as f:
        json.dump(data, f, indent=4)

    print(f"Patched file written to: {output_path}")


if __name__ == "__main__":
    main()