# Helper Scripts Overview

This directory contains utility scripts used in the PQKryvos Circom pipeline.  
These scripts support circuit compilation, witness generation, and other preprocessing tasks.

---

## `generate_r1cs.py`

**Purpose:**  
Compile a `.circom` circuit to r1cs, producing multiple outputs (R1CS, WASM, C, JSON) and store compilation logs.
(**Note:** Depending on the circuit, compiling to R1CS can be highly time- and/or memory-consuming. For testing purposes, we provide precompiled circuits in the corresponding directory.)

**Usage:**

```bash
python generate_r1cs.py <circuit_file> [-o OUTFOLDER] [-p {goldilocks,bn254}]
```

**Arguments:**

* `circuit_file` - Path to the `.circom` circuit template.
* `-o, --outfolder` - Optional. Directory where compiled files will be saved.
* `-p, --prime` - Prime field to use. Choices are `goldilocks` (default) or `bn254`.

**Details:**

* Uses Circom compilation flags: `--O2`, `--r1cs`, `--wasm`, `--c`, `--json`.
* Generates:

  * JSON file with R1CS constraints (required for our libiop interface)
  * WASM for standard witness generation
  * C files for alternative witness generation
* Stores a compilation log containing numbers of public and private variables.
* Default prime field is **Goldilocks** unless `--prime bn254` is specified.

**Notes:**

* For most circuits, the WASM output is sufficient for witness creation, but the C output is provided as an alternative.
* The JSON output is mandatory for Ligero proof generation. We only used the --r1cs flag to generate the log file.

## `generate_input_skeleton.py`

**Purpose:**  
Generate a skeleton input JSON file for a `.circom` circuit, with all values initialized to `0`. The JSON contains fields and dimensions corresponding to the input signals defined in the circuit.

**Usage:**

```bash
python generate_input_skeleton.py <circuit_file> <output_file>
```

**Arguments:**

* `circuit_file` - Path to the .circom circuit template.

* `output_file` - Path where the generated JSON skeleton will be saved.

**Details:**

* Parses the .circom file to detect input signals, including multi-dimensional arrays.

* Evaluates variable assignments in the circuit to determine array sizes.

* Initializes scalar inputs to 0 and arrays to nested lists filled with 0.

* Prints the shapes of all input signals to the console for verification.

* Produces a JSON file compatible with Circom witness generation scripts.

**Notes:**

* The resulting input file is intended as a starting point; users must fill in actual input values before generating a valid witness (usually the all-zero arrays won't be valid for witness generation). For circuits that compute commitments, the `patch_randomness.py` script below can be used to initialize the randomness. 

## `patch_randomness.py`

**Purpose:**
Patch the `randomness` field of an input JSON file by replacing all entries with random values in the set
`{0, 1, -1 mod p}`.

This can be used for all of our circuits that compute BDLOP commitments. This script is intended to be used after generating an input skeleton with `generate_input_skeleton.py`.

**Usage:**

```bash
python patch_randomness.py <input_file> [-p {goldilocks,bn254}] [-o OUTPUT_FILE]
```

**Arguments:**

* `input_file` - Path to the input JSON file to patch.
* `-p, --prime` - Prime field to use. Choices:

  * `goldilocks` (default)
  * `bn254`
* `-o, --output` - Optional. Output file path. If not provided, the input file is overwritten.

**Notes:**

* The resulting JSON file can be used for witness generation if any further required inputs (e.g., the input message) are correctly set.

* Circuits containing more than one randomness field need to be patched manually. 

## `witness_generation.py`

**Purpose:**  
Uses nodejs/wasm to generate a witness for a Circom circuit from a valid input JSON file, and optionally export the public outputs to a separate JSON file. Converts the witness into both `.wtns` (binary) and JSON formats. The conversion to JSON requires snarkjs.

**Usage:**

```bash
python witness_generation.py <input_file> [-r R1CSFOLDER] [-c CIRCUITNAME] [-o OUTFOLDER] [--export-public --logfile LOGFILE --output-public PUBLIC_OUTPUT_FILE]
```

**Arguments:**

* `input_file` - Path to a valid input JSON file for the circuit.
* `-r, --r1csfolder` - Optional. Folder containing the `_js` folder of the compiled circuit. Defaults to the current working directory.
* `-c, --circuitname` - Optional. Circuit name (defaults to the folder ending with `_js`).
* `-o, --outfolder` - Optional. Folder to write the witness files. Defaults to `r1csfolder`.
* `--export-public` - Optional flag. Export only public outputs to a separate JSON file.
* `--logfile` - Optional. Path to the circuit log file (required if exporting public outputs).
* `--output-public` - Optional. Path to save the public output JSON (relative to `outfolder` if set).

**Details:**

* Runs `generate_witness.js` (from the `_js` folder) to create a `.wtns` witness file.
* Converts the `.wtns` witness into JSON using `snarkjs`.
* If `--export-public` is used:

  * Extracts only the public outputs based on the circuit log.
  * Requires that the circuit takes no public input.
  * E.g., this can be used for extracting the computed (public) commitment from a witness for a full commitment computation circuit.

**Notes:**

* Witness creation requires a valid input file. In particular, the all-zero inputs generated with `generate_input_skeleton.py` are usually not sufficient.

## `comkey_patching`

**Purpose:**  
Provide tooling for generating and patching commitment keys (comkeys) in our Circom circuits that compute BDLOP commitments. Our default circuit instantiations use placeholder commitment keys, where every value is set to `2`. These scripts allow replacing the placeholder with a fresh, random commitment key.

---

### `generate_random_comkey.py`

**Purpose:**  
Generate a new random commitment key (`comkey.json`) with specified dimensions and modulus.

**Usage:**

```bash
python generate_random_comkey.py [-n N] [-N M] [-k K] [-q MODULUS] -o comkey.json
```


**Arguments:**

* `-n` - Optional. Number of comkey rows -1 (default: 6 for Goldilocks), corresponds to d in paper.
* `-N` - Optional. Cyclotomic olynomial degree (default: 486 for Goldilocks).
* `-k` - Optional. Number of comkey columns (default: 13), corresponds to 2d+1 in paper.
* `-q` - Optional. Modulus (default: 18446744069414584321 for Goldilocks).
* `-o` - Output file path for the generated `comkey.json`.

**Details:**

* Generates a random matrix of shape `(n+1, k)` with entries being length-`N`-vectors in `[0,q]` (i.e., polynomials in `Rq`)
* The output JSON can be directly used to patch a circuit with a placeholder commitment key.

---

### `update_comkey.py`

**Purpose:**
Patch a Circom circuit that uses a placeholder BDLOP commitment key with a new key generated by `generate_random_comkey.py`.

**Usage:**

```bash
python update_comkey.py comkey.json circuit.circom patched_circuit.circom
```

**Arguments:**

* `comkey.json` - Path to the JSON file containing the new commitment key.
* `circuit.circom` - Original Circom circuit containing the placeholder commitment key.
* `patched_circuit.circom` - Optional. Output path for the updated circuit with the new key (if not given, the input circuit is overwritten).

**Details:**

* Replaces the default placeholder commitment key in the circuit with values from `comkey.json`.
* The patched circuit is ready for compilation and witness generation.

**Notes:**

* Assumes the circuit contains the default placeholder comkey (all values set to `2`).
* Cannot be applied to a circuit that has already been patched with a custom comkey.