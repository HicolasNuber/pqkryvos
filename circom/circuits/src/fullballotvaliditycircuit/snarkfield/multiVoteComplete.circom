pragma circom 2.2.2;

include "../../crypto/commitment.circom";
include "../../voting/multiVote.circom";

template computeMultiVoteComplete(bitsVotes,nVotes,maxVotesCand,maxChoices,N,n,k,comkey){
/**
 * Computes a commitment to a Multiple Choice Vote, assuming SNARK field == Lattice Field.
 *
 *   Vote parameters:
 *   - bitsVotes: number of bits used to encode each vote.
 *   - nVotes: number of choices/candidates.
 *   - maxVotesCand: maximal number of votes that can be assigned to a choice/candidate, should be < 2^bitsVotes
 *   - maxChoices: total number of votes that can be assigned
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

    component testMultiVote = assertMultiVoteVoting(bitsVotes, nVotes, maxVotesCand, maxChoices);
    for (var j=0; j<numcommitments; j++){
        for (var i=0; i<N; i++){
            if(j*N+i < nVotes){
                testMultiVote.ballot[j*N+i] <== message[j][i];
            }
        }
    }
}