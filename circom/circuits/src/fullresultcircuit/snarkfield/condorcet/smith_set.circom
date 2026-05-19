pragma circom 2.2.2;

include "../../../crypto/commitment.circom";
include "../../../tallying/utilities.circom";

template testCondorcetSmithSet(bits,nVotes,N,n,k,comkey){
/**
 * Computes a commitment to a Condorcet Vote, assuming SNARK field != Lattice Field.
 *
 *   Tally parameters:
 *   - bits: number of bits used to encode aggregated comparison matrix (should be >= log2(#voters))
 *   - nVotes: number of choices/candidates
 *
 *   Commitment parameters:
 *   - N: degree of the cyclotomic polynomial.
 *   - q: prime modulus < SNARK field modulus
 *   - n: commitment dimension - 1 (del Pino d)
 *   - k: randomness dimension (del Pino 2d+1)
 *   - comkey[n+1][k][N]: (n+1)xk matrix of degree-N-polynomials in Zq[X]
 */
    var matrixEntries = nVotes*nVotes; // Condorcet comparison matrix is (nVotes x nVotes) matrix; we roll out row-wise
    var numcommitments = (nVotes*nVotes \ N) +1;
    
    signal input tally[nVotes][nVotes];
    signal message[numcommitments][N]; // // committed message (= tally split into chunks of size N)
    signal input randomness[numcommitments][k][N];
    signal output commitment[numcommitments][n+1][N];
    signal output smithSet[nVotes];
    
    for (var j=0; j< numcommitments; j++){
        for (var i=0; i<N; i++){
            var msgidx = j*N+i;
            if (msgidx < nVotes*nVotes){
                var rowidx = msgidx \ nVotes; 
                var colidx = msgidx % nVotes;
                message[j][i] <== tally[rowidx][colidx];
            }
            else{
                    message[j][i] <== 0;
            }
        }
    }

    component computeCommitment[numcommitments];
    for (var i=0; i< numcommitments; i++){
        computeCommitment[i] = commitSnarkField(comkey,N,n,k);
        computeCommitment[i].x <== message[i];
        computeCommitment[i].r <== randomness[i];
        commitment[i] <== computeCommitment[i].commitment;
    }

    component resfunc = computeSmithSet(nVotes, bits);
    resfunc.tally <== tally;
    smithSet <== resfunc.out;

}
