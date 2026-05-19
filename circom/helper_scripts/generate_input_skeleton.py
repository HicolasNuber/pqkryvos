#!/usr/bin/env python3
import re
import json
import argparse

# -----------------------------
# Step 0: parse CLI arguments
# -----------------------------
parser = argparse.ArgumentParser(
    description="Generate input.json skeleton from a Circom template"
)
parser.add_argument("circuit_file", help="Path to the .circom circuit template")
parser.add_argument("output_file", help="Path to output JSON file")
args = parser.parse_args()

# -----------------------------
# Step 1: read the Circom file
# -----------------------------
with open(args.circuit_file, "r") as f:
    circom_code = f.read()

# -----------------------------
# Step 2: parse and evaluate variables (with expressions)
# -----------------------------
var_assignments = re.findall(r"var\s+(\w+)\s*=\s*([^;]+);", circom_code)

vars_found = {}

def safe_eval(expr, vars_dict):
    expr = expr.replace("\\", "//")  # Circom integer division
    return eval(expr, {"__builtins__": None}, vars_dict)

unresolved = {name: expr.strip() for name, expr in var_assignments}

while unresolved:
    progress = False
    for varname in list(unresolved.keys()):
        expr = unresolved[varname]
        try:
            value = safe_eval(expr, vars_found)
            vars_found[varname] = value
            del unresolved[varname]
            progress = True
        except NameError:
            continue

    if not progress:
        raise RuntimeError(f"Could not resolve variables: {unresolved}")

# -----------------------------
# Step 3: parse input signals
# -----------------------------
signal_pattern = r"(?:input signal|signal input)\s+(\w+)((?:\[[^\]]+\])+)?;"
inputs_found = re.findall(signal_pattern, circom_code)

def eval_size_expr(expr, vars_dict):
    expr_clean = expr.strip("[]").replace("\\", "//")
    return eval(expr_clean, {"__builtins__": None}, vars_dict)

def build_array(sizes):
    if not sizes:
        return 0
    return [build_array(sizes[1:]) for _ in range(sizes[0])]

def get_shape(arr):
    """
    Compute the shape of a nested list.
    Returns tuple like (d1, d2, ..., dn)
    """
    shape = []
    current = arr
    while isinstance(current, list):
        shape.append(len(current))
        if len(current) == 0:
            break
        current = current[0]
    return tuple(shape)

# -----------------------------
# Step 4: build input JSON
# -----------------------------
input_json = {}

print("Input shapes:")
for name, array_dims in inputs_found:
    if array_dims:
        dims = re.findall(r"\[[^\]]+\]", array_dims)
        sizes = [eval_size_expr(d, vars_found) for d in dims]
        input_json[name] = build_array(sizes)
        shape = get_shape(input_json[name])
        print(f"  {name}: {shape}")
    else:
        input_json[name] = 0
        print(f"  {name}: scalar")

# -----------------------------
# Step 5: write output file
# -----------------------------
with open(args.output_file, "w") as f:
    json.dump(input_json, f, indent=4)

print(f"\nGenerated {args.output_file} with inputs: {list(input_json.keys())}")