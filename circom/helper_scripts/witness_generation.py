#!/usr/bin/env python3
import argparse
import os
import subprocess
import json
import re

# -----------------------------
# CLI arguments
# -----------------------------
parser = argparse.ArgumentParser(description="Generate witness and optionally export public outputs")
parser.add_argument("input_file", help="Path to input.json")
parser.add_argument("-r", "--r1csfolder", default=None, help="Folder containing circuit_js directory")
parser.add_argument("-c", "--circuitname", default=None, help="Circuit name (defaults to folder ending with _js)")
parser.add_argument("-o", "--outfolder", default=None, help="Folder to write witness and public outputs")
parser.add_argument("--export-public", action="store_true", help="Export only public outputs")
parser.add_argument("--logfile", default=None, help="Circuit log file (needed for public outputs)")
parser.add_argument("--output-public", default=None, help="Path to save public output JSON (relative to outfolder if set)")
args = parser.parse_args()

# -----------------------------
# Step 0: determine r1cs folder
# -----------------------------
r1cs_folder = os.path.abspath(args.r1csfolder) if args.r1csfolder else os.getcwd()

# Step 1: determine circuit name
if args.circuitname:
    circuit_name = args.circuitname
else:
    candidates = [f for f in os.listdir(r1cs_folder) if f.endswith("_js") and os.path.isdir(os.path.join(r1cs_folder,f))]
    if len(candidates) != 1:
        raise ValueError("Cannot determine circuit name: specify -c or ensure exactly one folder ending with _js exists")
    circuit_name = candidates[0][:-3]  # strip "_js"

circuit_js_folder = os.path.join(r1cs_folder, f"{circuit_name}_js")

# Step 2: determine output folder
out_folder = os.path.abspath(args.outfolder) if args.outfolder else r1cs_folder
os.makedirs(out_folder, exist_ok=True)

witness_wtns = os.path.join(out_folder, "witness.wtns")
witness_json = os.path.join(out_folder, "witness.json")

# -----------------------------
# Step 3: run generate_witness.js
# -----------------------------
gen_witness_cmd = [
    "node",
    os.path.join(circuit_js_folder, "generate_witness.js"),
    os.path.join(circuit_js_folder, f"{circuit_name}.wasm"),
    os.path.abspath(args.input_file),
    witness_wtns
]

print("Running generate_witness.js...")
process = subprocess.run(gen_witness_cmd)
if process.returncode != 0:
    raise RuntimeError("Witness generation failed")

# -----------------------------
# Step 4: export json witness
# -----------------------------
export_json_cmd = ["snarkjs", "wtns", "export", "json", witness_wtns, witness_json]
print("Exporting witness to JSON...")
process = subprocess.run(export_json_cmd)
if process.returncode != 0:
    raise RuntimeError("Failed to export witness to JSON")

# -----------------------------
# Step 5: optionally export only public outputs
# -----------------------------
if args.export_public:
    if not args.logfile:
        # try to find log file in r1cs folder
        log_candidates = [f for f in os.listdir(r1cs_folder) if f.endswith(".log")]
        if len(log_candidates) != 1:
            raise ValueError("Cannot determine log file: provide --logfile")
        log_file_path = os.path.join(r1cs_folder, log_candidates[0])
    else:
        log_file_path = os.path.abspath(args.logfile)

    with open(log_file_path, "r") as f:
        log_text = f.read()

    # Extract number of public inputs and outputs
    public_inputs_match = re.search(r"public inputs\s*:\s*(\d+)", log_text)
    public_outputs_match = re.search(r"public outputs\s*:\s*(\d+)", log_text)

    n_inputs = int(public_inputs_match.group(1)) if public_inputs_match else 0
    n_outputs = int(public_outputs_match.group(1)) if public_outputs_match else 0

    if n_outputs == 0:
        print("No public outputs found in log; skipping public export")
    elif n_inputs > 0:
        raise RuntimeError("Both public inputs and public outputs are nonzero. "
                           "Automatic public extraction is ambiguous. Please extract manually.")
    else:
        # Load witness JSON (single array)
        with open(witness_json, "r") as f:
            w = json.load(f)

        # Extract entries 1..n_outputs (skip index 0)
        public_values = w[1:n_outputs+1]

        if not args.output_public:
            raise ValueError("Must provide --output-public to save public outputs")

        # If output_public is relative, join with out_folder
        output_public_path = os.path.join(out_folder, args.output_public) if not os.path.isabs(args.output_public) else args.output_public

        with open(output_public_path, "w") as f:
            json.dump(public_values, f, indent=4)

        print(f"Public outputs exported to {output_public_path}")