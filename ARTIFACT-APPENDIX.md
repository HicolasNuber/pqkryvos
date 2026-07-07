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




Recommendation: Run the artifact inside the provided Docker container, avoid disabling security features, and treat all included cryptographic code as untrusted.


## Basic Requirements


### Hardware Requirements




Minimal hardware requirements


- Can run on a laptop (no special hardware requirements) if precompiled circuits are used.
- For compiling large circuits (e.g., IRV), we recommend 64 GB RAM for the R1CS compilation and up to 20 GB free disk space if all circuits are generated
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


Compute time


- Ligero proof generation: 1–20 seconds depending on circuit size
- Verification: seconds
- Circom R1CS generation (if no precompiled circuits are used): Up to 24 hours (depending on circuits)


Disk space


- Repository: ~200 MB and additional space of 100 MB - 1 GB to store R1CS circuits after generation
- Precompiled circuits: up to ~10–15 GB (optional)




## Environment 


### Accessibility 


The artifact is hosted in a public GitHub repository:


https://github.com/HicolasNuber/PQKryvos


Precompiled circuits are hosted at:


https://mega.nz/folder/WqIXBBDY#kJomxXYf2HjKzL7Vjlu2tQ


Precompiled circuits are only available for the review process to reduce the reviewing time.
We cannot provide them publicly in a stable manner afterwards.
However, all our circuits can be compiled from source with circom as described below.


A stable commit hash will be provided after artifact evaluation.


### Set up the environment


Clone and build the Docker image:


```bash
git clone https://github.com/HicolasNuber/pqkryvos/
cd pqkryvos
docker build -t pq-kryvos-container .
```

> **Note:** The Docker image has been tested on Intel/Linux (amd64) systems. If you are building on a different architecture (e.g., Apple Silicon (arm64)), you may need to build the image using amd64 emulation: 
> ```bash
> $ docker build --platform linux/amd64 -t pq-kryvos-container .
> ```



(Optional) Download precompiled circuits from https://mega.nz/folder/WqIXBBDY#kJomxXYf2HjKzL7Vjlu2tQ.


Place downloaded directories inside ./precompiled_circuits/


### Testing the Environment


We provide a small test circuit to test the environment for both, the compilation procedure for compiling a circom file to r1cs (with accompanying input and witness generation) and running a Ligero proof.






To run the tests, run the container by executing


```bash
$ docker run --rm -it -v ./test:/app/test pq-kryvos-container
```

in the project root directory.

#### Testing Circuit Compilation and Input/Witness Generation


Follow the steps below sequentially.


##### 1. Circom Compilation 
Inside the container in `/app`, run


```bash
$ python3 circom/helper_scripts/generate_r1cs.py test/multiplication.circom -o test/compilation_output_goldilocks
$ python3 circom/helper_scripts/generate_r1cs.py test/multiplication.circom -o test/compilation_output_bn254 -p bn254   
```


to test the circom compilation. This should generate two directories `test/compilation_output_goldilocks` and `test/compilation_output_bn254`, each containing


```bash
multiplication_cpp/
multiplication_js/
multiplication.log
multiplication.r1cs
multiplication_constraints.json
```

These are all circuit-related (but input-/witness-agnostic) files required for creating a proof. This check confirms that circom compilation works as intended.


##### 2. Input Generation
To test input generation, run 


```bash
$ python3 circom/helper_scripts/generate_input_skeleton.py test/multiplication.circom test/compilation_output_goldilocks/input.json
$ python3 circom/helper_scripts/generate_input_skeleton.py test/multiplication.circom test/compilation_output_bn254/input.json
```


which generates a file `input.json` with content `{"a": 0, "b": 0}` in the respective folder. These are the circuit input files required for creating a proof.
This check confirms that input generation works as intended.

##### 3. Witness Generation
To test witness generation, run


```bash
$ python3 circom/helper_scripts/witness_generation.py test/compilation_output_goldilocks/input.json -r test/compilation_output_goldilocks/
$ python3 circom/helper_scripts/witness_generation.py test/compilation_output_bn254/input.json -r test/compilation_output_bn254/
```


which generates files `witness.wtns` and `witness.json` in the respective folder. The file `witness.json` has content `["1", "0", "0", "0"]`. These are all intermediate circuit values computed when evaluating the circuit on the input defined in step 2. This check confirms that witness generation works as intended.


After completing this step, the directories `test/compilation_output_goldilocks/` and `test/compilation_output_bn254/` should have the same contents as the provided directories `test/bn254` and `test/goldilocks`, respectively.


#### Testing Proof Generation and Verification


Inside the container in `/app`, run


```bash
$ ./ligero test/goldilocks/multiplication_constraints.json test/goldilocks/multiplication.log test/goldilocks/witness.json
$ ./ligero_BN254 test/bn254/multiplication_constraints.json test/bn254/multiplication.log test/bn254/witness.json
```


Expected output:


- R1CS statistics
- Ligero parameter summary
- Proof generation time
- Automatic verification success message

This check confirms that proof generation verification are functioning correctly. are functioning correctly. After the tests complete successfully, you can close the container and proceed with the artifact evaluation experiments described in the next section, which reproduce the results from the paper using the benchmark circuits.

## Artifact Evaluation


### Main Results and Claims


#### Main Result: Generation of R1CS constraints with Circom and zkSNARKS for ballot validity and tally-hiding


The artifact provides Circom circuits and Libiop-based Ligero proof generation, demonstrating efficient BDLOP commitment and ballot validity proofs.
We then provide zkSNARKs with Ligero for ballot validity and tally-hiding for a large variety of e-voting schemes (see paper for further details). All results presented in our paper refer to Experiment 2.


### Experiments




#### Experiment 1: Compiling Circom Circuits to R1CS and Generating Inputs/Witnesses


> [!WARNING] Depending on the circuit, compilation to R1CS can be CPU‑ and/or time-intensive. For convenience, we provide pre-compiled circuits alongside example witnesses under the link specified above. We recommend using the precompiled files and proceed with Experiment 2 for reproducing our results.


To compile a circom circuit to R1CS, start by running the container using 
```bash
$ docker run --rm -it pq-kryvos-container
```


inside the project's root directory.


Then, follow the helper_scripts as specified in `circom/README.md`.


For example, to generate the R1CS and witness file for proving knowledge of an opening of a BDLOP commitment over the Goldilocks field, run 


```bash
$ python3 circom/helper_scripts/generate_r1cs.py circom/circuits/benchmark/ballotvalidity/goldilocks/Commitment/goldilocks_N486_n6.circom -o [R1CS_FOLDER] -p goldilocks
```
with `[R1CS_FOLDER]` changed to the desired output directory.


To generate an input skeleton for the circuit, run 


```bash
$ python3 circom/helper_scripts/generate_input_skeleton.py circom/circuits/benchmark/ballotvalidity/goldilocks/Commitment/goldilocks_N486_n6.circom [R1CS_FOLDER]/input.json
```


The generated input can be adapted by manually adapting the `input.json` file. In this example, the input consists of the committed values and the used randomness. The randomness can also be patched using the `patch_randomness.py` script inside `circom/helper_scripts/`.


Finally, to generate a witness for the circuit, run


```bash
$ python3 circom/helper_scripts/witness_generation.py [R1CS_FOLDER]/input.json [R1CS_FOLDER]
```
After these steps, `[R1CS_FOLDER]` contains the necessary files for proof generation: A JSON-file containing the R1CS, a compilation log specifiying the number of public/private inputs, and a JSON-file containing the witness.


For more details on the circuits and helper scripts, please refer to the README files in the `circom` directory and subdirectories.


#### Experiment 2: Computing Ligero Proofs over BN254 and Goldilocks


To compute/verify a proof, run the container over a directory `PATH` that contains (subdirectories that each contain)
- a JSON file containing the R1CS, as created by circom with the option --json
- a circom log file specifying the number of public/private in-/outputs
- a JSON file containing the satisfying witness vector for the R1CS


by running 
```bash
$ docker run --rm -it -v PATH/:/app/precompiled_circuits pq-kryvos-container
```
in the project's root directory.

All circuits in `precompiled_circuits` come with these three files for your convenience. Similarly, all directories generated as described in Experiment 1 should contain these three files. A fresh witness can be generated by adapting the respective input files and running the witness generation script found in `circom/helper_scripts`. To start, we recommend using the precompiled circuits with precomputed witnesses. 


To run the container over `precompiled_circuits`, run




```bash
$ docker run --rm -it -v ./precompiled_circuits/:/app/precompiled_circuits pq-kryvos-container
```


inside the project's root directory.


Then, inside the container, prove the satisfiability of the circuit over Goldilocks by running


```bash 
$./ligero [constraints.json] [compilation.log] [witness.json]
```


Prove the satisfiability of the circuit over BN254 (with del Pino parameters) by running


```bash 
$./ligero_BN254 [constraints.json] [compilation.log] [witness.json]
```


##### Runtime Output


When generating a proof, you will see:
- Information about the R1CS
- Ligero parameters used in libiop, including:
  - Hash function
  - Hash length
  - Achieved security parameter
- Benchmarks for proving and verification times


Verification is automatically triggered on the freshly generated proof.


##### Example Circuits


We use some examples from `precompiled_circuits` that illustrate how to use Ligero for computing proofs. The example commands below assume that `PATH` is the specified directory from `precompiled_circuits`, if `PATH` is a parent directory, adapt the commands accordingly:


###### 1. Proving Knowledge of an Opening of a BDLOP commitment (cf. Section 5.2)


Over Goldilocks: (`PATH = precompiled_circuits/ballotvalidity/goldilocks/Commitment/`)


```bash  
$ ./ligero precompiled_circuits/goldilocks_N486_n6_constraints.json precompiled_circuits/goldilocks_N486_n6.log precompiled_circuits/witness.json
```


Over BN254: (`PATH = precompiled_circuits/ballotvalidity/delPino/Commitment/`)


```bash  
$ ./ligero_BN254 precompiled_circuits/delPino_N256_n7_constraints.json precompiled_circuits/delPino_N256_n7.log precompiled_circuits/witness.json
```


###### 2. Proving Ballot Validity of a BDLOP-committed ballot (over Goldilocks) (cf. Section 5.3; see Appendix B for the defined ballot formats)


Single-Vote with 480 candidates: (`PATH = precompiled_circuits/ballotvalidity/goldilocks/SingleVote/bitsVotes1nVotes480/`)


```bash  
$ ./ligero precompiled_circuits/singleVoteComplete_bitsVotes1_nVotes480_constraints.json precompiled_circuits/singleVoteComplete_bitsVotes1_nVotes480.log precompiled_circuits/witness.json
```


Pointlist Borda with 200 candidates: (`PATH = precompiled_circuits/ballotvalidity/goldilocks/PointlistBorda/bitsVotes32nVotes200nPoints200orderedPoints2001991/`)


```bash  
$ ./ligero precompiled_circuits/pointlistBordaComplete_bitsVotes32_nVotes200_nPoints200_orderedPointslist200_782862e8_constraints.json precompiled_circuits/pointlistBordaComplete_bitsVotes32_nVotes200_nPoints200_orderedPointslist200_782862e8.log precompiled_circuits/witness.json
```


###### 3. Proving Correct Result Computation from aggregated BDLOP-committed ballots (over Goldilocks) (cf. Section 5.3; see Appendix B for the defined result functions)


Set of candidate(s) from a total of 100 candidates who received the most votes: (`PATH = precompiled_circuits/tallying/goldilocks/MostVotes/bits32nVotes100/`)


```bash  
$ ./ligero precompiled_circuits/most_votes_bits32_nVotes100_constraints.json precompiled_circuits/most_votes_bits32_nVotes100.log precompiled_circuits/witness.json
```


###### 4. Proving a Linear Relation between BDLOP-commited values (over Goldilocks) (cf. Section 5.2)


Proving that C1,C2 are BDLOP commitments to x_1 resp. x_2 such that ax_1+bx_2 = 0 for public polynomials a,b: (`PATH = /precompiled_circuits/linearRelations/`)


```bash  
$ ./ligero precompiled_circuits/linearRelationTest_constraints.json precompiled_circuits/linearRelationTest.log precompiled_circuits/witness.json
```


##### Troubleshooting


Common causes of errors:


1. **Incorrect Ligero binary**
   - Use `./ligero` for Goldilocks proofs and `./ligero_BN254` for BN254 proofs.  
   - Mixing binaries will typically cause failures.


2. **Incorrect input order**
   - Inputs must always be provided in the order: **Constraints, Log, Witness**.


## Limitations




- Full R1CS compilation of large circuits has high memory requirements and slow runtimes. Precompiled circuits are provided for convinience.


- The artifact does not implement the full PQKryvos voting system (talliers, bulletin board, networking). It focuses on the cryptographic proof components used in the evaluation.


Despite these limitations, all performance‑critical and correctness‑critical results from the paper are reproducible.


## Notes on Reusability (Encouraged for all badges)


- Circom circuits can be adapted to new ballot formats by modifying constraint definitions.
- The libiop-based Ligero prover can be reused for any R1CS‑based proof system. In particular, our realization of arithmetic in cyclotomic ring might be useful for other applications


The artifact serves as a general framework for building post‑quantum ZK‑based e‑voting components and constraint systems for cryptographic applications over cyclotomic rings.

