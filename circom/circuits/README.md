# Circom Circuits

This directory contains all Circom circuits used in PQKryvos, organized by type and purpose. The circuits cover various relations, including BDLOP commitments, ballot validity, and result computation, as well as many building blocks for these computations.

---

## Directory Overview

### `libs/`
Contains circuits from **circomlib** that are partially used by our circuits.

### `src/`
Contains reusable building blocks and templates for circuits, including:
- Commitment computation
- Ballot validity checks
- Result computation
- Polynomial and modular arithmetic
- Linear relations on committed values

**Notes:**
- Circuits in `src/` are not instantiated; they serve as templates.  
- To generate R1CS from a `src/` circuit, a wrapper circuit must be written that specifies all input and output variables.

### `benchmark/`
Contains wrapper circuits for all major relations:

1. **`choicespace_membership`**  
   - Built from `src/voting` templates.  
   - Ensures that a plain input ballot obeys the rules of the specified choicespace.

2. **`ballotvalidity`**  
   - Built from `src/fullballotvaliditycircuit`.  
   - Ensures choicespace membership, computes one or more BDLOP commitments to the input ballot, and enforces that the input randomness used for the BDLOP commitment is small.

3. **`tallying`**  
   - Built from `src/fullresultcircuit`.  
   - Computes BDLOP commitment(s) to the aggregated input tally vector with small input randomness and evaluates the election result according to `f_res`.

**Notes:**
- Instantiations cover all choice spaces and candidate numbers specified in the paper.  
- Precompiled R1CS is provided for one candidate number per choice space, for `choicespace_membership`, `ballotvalidity`, and `tallying`, in the `precompiled_circuits/` folder at the project root.

### Commitment-only Circuits
- **`ballotvalidity/goldilocks/Commitment`** – Computes a single BDLOP commitment over Goldilocks (ensuring small randomness).  
- **`ballotvalidity/delPino/Commitment`** – Computes a single BDLOP commitment over BN254 (ensuring small randomness).  
- **`linearRelation/`** – Ensures a linear relation between two committed values.

**Notes:**
- All commitment circuits (ballotvalidity, tallying, commitment-only) are defined for the BDLOP parameters over Goldilocks from our paper, except `ballotvalidity/delPino/Commitment`, which uses the parameters from delPino.