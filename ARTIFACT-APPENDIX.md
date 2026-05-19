# Artifact Appendix

Paper title: PQKryvos: Post-Quantum Secure E-Voting With Flexible Ballot Formats and Public Tally-Hiding

Requested Badge(s):
  - [x] **Available**
  - [x] **Functional**
  - [x] **Reproduced**

## Description 

This project implements the Ligero proofs used for our paper **"PQKryvos: Post-Quantum Secure E-Voting With Flexible Ballot Formats and Public Tally-Hiding"** by Nicolas Huber, Ralf Küsters and Pascal Reisert (PoPETs 2026), via circom circuits for computing BDLOP commitments, and/or ensuring ballot validity, and/or ensuring correct result computation. It uses libiop for generating Ligero proofs based on these circuits.  
We provide everything needed to compile circuits, generate witnesses, and run proofs in a reproducible Docker environment.

### Security/Privacy Issues and Ethical Concerns 

This artifact implements and evaluates the PQKryvos e‑voting protocol, which combines lattice‑based homomorphic commitments and general‑purpose zero‑knowledge proofs (GPZKPs). While the protocol itself is designed for strong privacy and verifiability, the artifact implementation may introduce risks for the machine of an evaluator. The following points describe these risks clearly and explicitly:

- Native cryptographic code may contain memory‑safety bugs. The BDLOP commitment implementation and zkSNARK prover involve large‑integer and polynomial arithmetic, which can crash or behave unpredictably if compiled with unsafe optimizations.

- High resource usage. Generating GPZKPs can be CPU‑intensive, potentially causing system slowdown or excessive memory consumption.

- Potential weakening of system protections. Reproducing benchmarks may tempt evaluators to disable ASLR, stack protections, or use unsafe compiler flags, increasing exposure to vulnerabilities.

- Untrusted dependencies. The artifact relies on external libraries for commitments, R1CS compilation, and zkSNARKs, which may contain unpatched security issues.


Recommendation: Run the artifact inside a VM or container, avoid disabling security features, and treat all included cryptographic code as untrusted. We provide a docker container below.

## Basic Requirements

### Hardware Requirements


Minimal hardware requirements

- Can run on a laptop (no special hardware requirements) if precompiled circuits are used.
- For large circuits (e.g., IRV), we recommend 64 GB RAM for the R1CS compilation and up to 20 GB free disk space if all circuits are generated
- All experiments can be executed on commodity hardware or cloud VMs.

Hardware used for experiments in the paper (for Reproduced badge)

- Lenovo ThinkPad with an Intel i7-6600U CPU running at 2.60GHz and 12GB of RAM running Ubuntu 22.04 LTS

### Software Requirements

Operating System

- Artifact tested on Ubuntu 22.04.
- Any Linux distribution with Docker support should work.

Required OS packages

- Docker Engine ≥ 20.10

- (Optional) Node.js, circom, snarkjs, Python 3.10+ for running helper scripts outside Docker.

Container runtime

- Docker 20.10+ (used to build and run the artifact).

Programming languages / compilers inside Docker:

- C++17 toolchain (for libiop)
- Node.js + circom compiler
- Python 3.x
- All required versions are included in the Docker image.

Dependencies

- circom 2.x
- snarkjs 0.6.x
- libiop (included in repository)
- Custom Goldilocks field implementation (included)
- No proprietary software required.

Machine Learning Models

- Not applicable.

Datasets

- No datasets required.

- (Optional) Precompiled circuits can be downloaded separately: https://mega.nz/folder/WqIXBBDY#kJomxXYf2HjKzL7Vjlu2tQ

### Estimated Time and Storage Consumption


Human time

- Setup: ~10 minutes
- Running example proofs: 1–5 minutes
- Running large circuits: several minutes per proof
- Cirom R1CS generation (if no precomputed circuits are used)

Compute time

- Ligero proof generation: 1–20 seconds depending on circuit size
- Verification: seconds

Disk space

- Repository: ~200 MB and additional space of 100 MB - 1 GB to store R1CS circuits after generation
- Precompiled circuits: up to ~10–15 GB (optional)


## Environment 

### Accessibility 

The artifact is hosted in a public GitHub repository:

https://github.com/HicolasNuber/PQKryvos

to be published after acceptance.

Precompiled circuits are hosted at:

https://mega.nz/folder/WqIXBBDY#kJomxXYf2HjKzL7Vjlu2tQ

Precompiled circuits are only available for the review process to reduce the reviewing time
We cannot provide them publicly in a stable manner afterwards.
However, all our circuits can be compiled from source with circom as described below.

A stable commit hash will be provided after artifact evaluation.

### Set up the environment

Clone and build the Docker image:

```bash
git clone https://github.com/<your-repo>/PQKryvos.git
cd PQKryvos
docker build -t pq-kryvos-container .
```

(Optional) Download precompiled circuits from https://mega.nz/folder/WqIXBBDY#kJomxXYf2HjKzL7Vjlu2tQ.

Place downloaded directories inside ./precompiled_circuits/

```bash
git clone git@github.com:PoPETS-AEC/example-docker-python-pip.git
docker build -t example-docker-python-pip:main .
```

### Testing the Environment

Launch the container:

```bash
docker run --rm -it -v ${PWD}/precompiled_circuits:/app/precompiled_circuits pq-kryvos-container
```

Inside the container, run a small example:

```
./ligero precompiled_circuits/example/constraints.json \
         precompiled_circuits/example/compilation.log \
         precompiled_circuits/example/witness.json
```

Expected output:

- R1CS statistics
- Ligero parameter summary
- Proof generation time
- Automatic verification success message

## Artifact Evaluation

### Main Results and Claims

#### Main Result 1: Generation of R1CS constraints with Circom and zkSNARKS for ballot validity and tally-hiding

The artifact provides Circom circuits and Libiop-based Ligero proof generation, demonstrating efficient BDLOP commitment and ballot validity proofs.
We then provide zkSNARKs with Ligero for ballot validity and tally-hiding for a large variety of e-voting schemes (see paper for further details).

### Experiments


#### Experiment 1: Generation of R1CS constraints with Circom and generation of zk-Proofs


##### Directory Structure

###### `circom/`
- **`helper_scripts/`**: Scripts for  
  - Compiling `.circom` files to R1CS (**Note:** Depending on the circuit, compiling to R1CS can be highly time- and/or memory-consuming. For testing purposes, we provide precompiled circuits in the corresponding directory.)
  - Generating input skeleton files from circuits (to be filled out manually according to the desired input)
  - Computing witnesses using circom witness generation and prepared inputs
  - Patching commitment computation circuits with new commitment keys
- **`circuits/`**: Raw, uninstantiated circuit definitions. Modify or compile these as needed.

###### `precompiled_circuits/`
- This directory is intended to contain precompiled circuit instantiations. They are not included in this repository due to size limitations. Each precompiled circuit directory contains:
  - R1CS constraints (in JSON formats)  
  - Matching input files  
  - Corresponding witness files  
  - Compilation logs
- **Note:** Precompiled circuits can be very large. It is recommended to **mount at runtime** rather than copying the directory into Docker images and/or including only the concrete circuit needed.

###### `libiop/`
- The **libiop library** for Ligero proofs, including:  
  - Custom Goldilocks field implementation  
  - Patches for creating Ligero proofs from Circom-generated R1CS, witness and compilation logs.  
- Contains the main binaries `ligero` (for proving over Goldilocks) and `ligero_BN254`(for proving over BN254).

---

##### Getting Started

###### Prerequisites
- **Docker** (v20+ recommended)  
- Enough **free disk space** if using the whole `precompiled_circuits` (alternatively, just download the precompiled circuit desired)

Optional: Circom, snarkjs, Node and Python installed locally for running scripts outside Docker.

---

###### 1. Build the Docker Image
From the project root:

```bash
docker build -t pq-kryvos-container .
```

###### 2. Run the Container

To compute/verify a proof, run the container over a directory PATH that contains (subdirectories that each contain)
- a JSON file containing the R1CS, as created by circom with the option --json
- a circom log file specifying the number of public/private in-/outputs
- a JSON file containing the satisfying witness vector for the R1CS,

by running 

```bash
$ docker run --rm -it -v PATH:/app/precompiled_circuits pq-kryvos-container
```

All circuits in precompiled_circuits come with these three files for your convenience, but a fresh witness can be generated by adapting the respective input files and running the witness generation script found in `circom/helper_scripts/witness_generation`. To start, we recommend using the precompiled circuits with precomputed witnesses. When using custom circuits, we recommend using the R1CS generation script found in `circom/helper_scripts/r1cs_generation/`, as it takes care of generating the correct files. See the circom directory for further instructions.

###### 3. Compute Ligero Proofs over Goldilocks and BN254

To compute Ligero proofs for the precompiled circuits in ./precompiled_circuits/ run:

```bash
$ docker run --rm -it -v ./precompiled_circuits/:/app/precompiled_circuits pq-kryvos-container
```

Then, inside the container, prove the satisfiability of the circuit over Goldilocks by running

```bash 
$./ligero [constraints.json] [compilation.log] [witness.json]
```

Prove the satisfiability of the circuit over BN254 (with del Pino parameters) by running

```bash 
$./ligero_BN254 [constraints.json] [compilation.log] [witness.json]
```

####### Runtime Output

When generating a proof, you will see:
- Information about the R1CS
- Ligero parameters used in libiop, including:
  - Hash function
  - Hash length
  - Achieved security parameter
- Benchmarks for proving and verification times

Verification is automatically triggered on the freshly generated proof.

###### 4. Example Circuits

We use some examples from `precompiled_circuits` that illustrate how to use Ligero for computing proofs. The example commands below assume that PATH is the specified directory from `precompiled_circuits`:

####### 4.1. Proving Knowledge of an Opening of a BDLOP commitment

Over Goldilocks: (`precompiled_circuits/ballotvalidity/goldilocks/Commitment/`)

```bash  
$ ./ligero precompiled_circuits/goldilocks_N486_n6_constraints.json precompiled_circuits/goldilocks_N486_n6.log precompiled_circuits/witness.json
```

Over BN254: (`precompiled_circuits/ballotvalidity/delPino/Commitment/`)

```bash  
$ ./ligero_BN254 precompiled_circuits/delPino_N256_n7_constraints.json precompiled_circuits/delPino_N256_n7.log precompiled_circuits/witness.json
```

####### 4.2. Proving Ballot Validity of a BDLOP-committed ballot (over Goldilocks)

Single-Vote with 480 candidates: (`precompiled_circuits/ballotvalidity/goldilocks/SingleVote/bitsVotes1nVotes480/`)

```bash  
$ ./ligero precompiled_circuits/singleVoteComplete_bitsVotes1_nVotes480_constraints.json precompiled_circuits/singleVoteComplete_bitsVotes1_nVotes480.log precompiled_circuits/witness.json
```

Pointlist Borda with 200 candidates: (`precompiled_circuits/ballotvalidity/goldilocks/PointlistBorda/bitsVotes32nVotes200nPoints200orderedPoints2001991/`)

```bash  
$ ./ligero precompiled_circuits/pointlistBordaComplete_bitsVotes32_nVotes200_nPoints200_orderedPointslist200_782862e8_constraints.json precompiled_circuits/pointlistBordaComplete_bitsVotes32_nVotes200_nPoints200_orderedPointslist200_782862e8.log precompiled_circuits/witness.json
```

####### 4.3. Proving Correct Result Computation from aggregated BDLOP-committed ballots (over Goldilocks)

Set of candidate(s) from a total of 100 candidates who received the most votes: (`precompiled_circuits/tallying/goldilocks/MostVotes/bits32nVotes100/`)

```bash  
$ ./ligero precompiled_circuits/most_votes_bits32_nVotes100_constraints.json precompiled_circuits/most_votes_bits32_nVotes100.log precompiled_circuits/witness.json
```

####### 4.4 Proving a Linear Relation between BDLOP-commited values (over Goldilocks)

Proving that C1,C2 are BDLOP commitments to x_1 resp. x_2 such that ax_1+bx_2 = 0 for public polynomials a,b: (`/precompiled_circuits/linearRelations/`)

```bash  
$ ./ligero precompiled_circuits/linearRelationTest_constraints.json precompiled_circuits/linearRelationTest.log precompiled_circuits/witness.json
```

###### Troubleshooting

Common causes of errors:

1. **Incorrect Ligero binary**
   - Use `./ligero` for Goldilocks proofs and `./ligero_BN254` for BN254 proofs.  
   - Mixing binaries will typically cause failures.

2. **Incorrect input order**
   - Inputs must always be provided in the order: **Constraints,Log,Witness**.

## Limitations


- Full R1CS compilation of large circuits has high memory requirements and slow runtimes. Precompiled circuits are provided instead.

- The artifact does not implement the full PQKryvos voting system (talliers, bulletin board, networking). It focuses on the cryptographic proof components used in the evaluation.

Despite these limitations, all performance‑critical and correctness‑critical results from the paper are reproducible.

## Notes on Reusability (Encouraged for all badges)

- Circom circuits can be adapted to new ballot formats by modifying constraint definitions.
- The libiop-based Ligero prover can be reused for any R1CS‑based proof system. In particular, our realization of arithmetic in cyclotomic ring might be useful for other applications

The artifact serves as a general framework for building post‑quantum ZK‑based e‑voting components and constraint systems for cryptographic applications over cyclotomic rings.


