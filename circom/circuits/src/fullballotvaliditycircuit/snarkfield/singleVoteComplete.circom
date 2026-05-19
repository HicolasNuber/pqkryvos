pragma circom 2.2.2;

include "../../crypto/commitment.circom";
include "../../voting/singleVote.circom";

template computeSingleVoteComplete(nVotes,N,n,k,comkey){
/**
 * Computes a commitment to a Single Choice Vote, assuming SNARK field == Lattice Field.
 *
 *   Vote parameters:
 *   - nVotes: number of choices/candidates.
 *
 *   Commitment parameters:
 *   - N: degree of the cyclotomic polynomial.
 *   - n: commitment dimension - 1 (del Pino d)
 *   - k: randomness dimension (del Pino 2d+1)
 *   - comkey[n+1][k][N]: (n+1)xk matrix of degree-N-polynomials in Zq[X]
 */

    var numcommitments = (nVotes \ N) +1;

    signal input message[numcommitments][N];
    signal input randomness[numcommitments][k][N];
    signal output commitment[numcommitments][n+1][N];

    component computeCommitment[numcommitments];
    for (var i=0; i< numcommitments; i++){
        computeCommitment[i] = commitSnarkField(comkey,N,n,k);
        computeCommitment[i].x <== message[i];
        computeCommitment[i].r <== randomness[i];
        commitment[i] <== computeCommitment[i].commitment;
    }

    component testSingleVote = assertSingleVoteVoting(1, nVotes);
    for (var j=0; j<numcommitments; j++){
        for (var i=0; i<N; i++){
            if(j*N+i < nVotes){
                testSingleVote.ballot[j*N+i] <== message[j][i];
            }
        }
    }
}