pragma circom 2.2.2;

include "../../../crypto/commitment.circom";
include "../../../tallying/utilities.circom";

template testMostVotesTallyLattice(bits,nVotes,N,q,n,k,comkey){
/**
 * Computes a commitment to a Single-Choice/Multiple-Choice/Borda tally and the candidate(s) who received the most votes/points.
 *
 *   Tally parameters:
 *   - bits: number of bits for tally entries, should be at least ceil(log2(#Voters * highest assignable value))
 *   - nVotes: number of choices/candidates.
 *
 *   Commitment parameters:
 *   - N: degree of the cyclotomic polynomial.
 *   - q: prime modulus < SNARK field modulus
 *   - n: commitment dimension - 1 (del Pino d)
 *   - k: randomness dimension (del Pino 2d+1)
 *   - comkey[n+1][k][N]: (n+1)xk matrix of degree-N-polynomials in Zq[X]
 */
    var numcommitments = (nVotes \ N) +1;

    signal input message[numcommitments][N];
    signal input randomness[numcommitments][k][N];
    signal output commitment[numcommitments][n+1][N];
    signal output winnerIdx[nVotes];

    component computeCommitment[numcommitments];
    for (var i=0; i< numcommitments; i++){
        computeCommitment[i] = commit(comkey,N,n,k,q);
        computeCommitment[i].x <== message[i];
        computeCommitment[i].r <== randomness[i];
        commitment[i] <== computeCommitment[i].commitment;
    }

    component resfunc = computeMaximumIndicator(nVotes, bits);

    for (var j=0;j<numcommitments;j++){
        for (var i=0;i<N; i++){
            var msgidx = j*N+i;
            if(msgidx < nVotes){
            resfunc.tally[msgidx] <== message[j][i];
            }
        }
    }
    winnerIdx <== resfunc.indices;
}