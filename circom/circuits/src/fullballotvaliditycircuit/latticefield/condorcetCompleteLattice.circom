pragma circom 2.2.2;

include "../../crypto/commitment.circom";
include "../../voting/condorcet.circom";

template computeCondorcetCompleteLattice(bitsVotes,nVotes,N,q,n,k,comkey){
/**
 * Computes a commitment to a Condorcet Vote, assuming SNARK field != Lattice Field.
 *
 *   Vote parameters:
 *   - bitsVotes: number of bits used to encode ranks
 *   - nVotes: number of choices/candidates, should be < 2^bitsVotes
 *
 *   Commitment parameters:
 *   - N: degree of the cyclotomic polynomial.
 *   - q: prime modulus < SNARK field modulus
 *   - n: commitment dimension - 1 (del Pino d)
 *   - k: randomness dimension (del Pino 2d+1)
 *   - comkey[n+1][k][N]: (n+1)xk matrix of degree-N-polynomials in Zq[X]
 */
    var matrixEntries = nVotes*nVotes; // Condorcet Ballots  Ballot is (nVotes x nVotes) matrix; we roll out row-wise
    var numcommitments = (nVotes*nVotes \ N) +1;
    
    signal input ranking[nVotes]; // additional input from which the actual vote is computed
    signal vote[nVotes][nVotes]; // actual vote
    signal message[numcommitments][N]; // // committed message (= vote split into chunks of size N)
    signal input randomness[numcommitments][k][N];
    signal output commitment[numcommitments][n+1][N];

    component computeVote = computeCondorcetBallot(nVotes, bitsVotes);
    computeVote.ranking <== ranking;
    vote <== computeVote.out;

    for (var j=0; j< numcommitments; j++){
        for (var i=0; i<N; i++){
            var msgidx = j*N+i;
            if (msgidx < nVotes*nVotes){
                var rowidx = msgidx \ nVotes; 
                var colidx = msgidx % nVotes;
                message[j][i] <== vote[rowidx][colidx];
            }
            else{
                    message[j][i] <== 0;
            }
        }
    }
    
    component computeCommitment[numcommitments];
    for (var i=0; i< numcommitments; i++){
        computeCommitment[i] = commit(comkey,N,n,k,q);
        computeCommitment[i].x <== message[i];
        computeCommitment[i].r <== randomness[i];
        commitment[i] <== computeCommitment[i].commitment;
    }
}
