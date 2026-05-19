#!/usr/bin/env python3
import argparse
import subprocess
import os
import re

# -----------------------------
# Step 0: parse CLI arguments
# -----------------------------
parser = argparse.ArgumentParser(description="Compile a Circom circuit with WASM, C, JSON outputs and save logs.")
parser.add_argument("circuit_file", help="Path to the .circom circuit template")
parser.add_argument("-o", "--outfolder", default=None, help="Output folder for compiled files")
parser.add_argument("-p", "--prime", choices=["goldilocks", "bn254"], default="goldilocks", help="Prime field to use (default: goldilocks)")
args = parser.parse_args()

circuit_file = os.path.abspath(args.circuit_file)
circuit_name = os.path.splitext(os.path.basename(circuit_file))[0]

# -----------------------------
# Step 1: determine output folder
# -----------------------------
if args.outfolder:
    output_folder = os.path.abspath(args.outfolder)
else:
    output_folder = os.path.dirname(circuit_file)

os.makedirs(output_folder, exist_ok=True)

# -----------------------------
# Step 2: build circom command
# -----------------------------
cmd = ["circom", circuit_file, "--O2", "--r1cs", "--wasm", "--c", "--json", "-o", output_folder]

if args.prime == "goldilocks":
    cmd += ["--prime", "goldilocks"]
# BN254 does not need extra flag, Circom defaults to BN254

# -----------------------------
# Step 3: run the command and capture logs
# -----------------------------
log_file_path = os.path.join(output_folder, f"{circuit_name}.log")
ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')

with open(log_file_path, "w") as log_file:
    process = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    clean_output = ansi_escape.sub("", process.stdout.decode())
    log_file.write(clean_output)

if process.returncode == 0:
    print(f"Compilation finished successfully. Log saved to {log_file_path}")
else:
    print(f"Compilation failed. Check log at {log_file_path}")