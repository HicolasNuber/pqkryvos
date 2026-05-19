pragma circom 2.2.2;

include "../../crypto/commitment.circom";
include "../../voting/bordaTournamentStyle.circom";

template computeBordaTournamentStyleComplete(bitsVotes,nVotes,a,b,N,n,k,comkey){
/**
 * Computes a commitment to a Borda Tournament Style Vote, assuming SNARK field == Lattice Field.
 *
 *   Vote parameters:
 *   - bitsVotes: number of bits used to encode ranks
 *   - nVotes: number of choices/candidates, should be < 2^bitsVotes
 *   - a: points assigned per worse-ranked candidate.
 *   - b: points assigned per equally-ranked candidate.
 *
 *   Commitment parameters:
 *   - N: degree of the cyclotomic polynomial.
 *   - n: commitment dimension - 1 (del Pino d)
 *   - k: randomness dimension (del Pino 2d+1)
 *   - comkey[n+1][k][N]: (n+1)xk matrix of degree-N-polynomials in Zq[X]
 */

    var numcommitments = (nVotes \ N) +1;  

    signal input ranking[nVotes]; // additional input from which the vote is computed
    signal vote[nVotes]; // actual vote
    signal message[numcommitments][N]; // committed message (= vote split into chunks of size N)
    signal input randomness[numcommitments][k][N];
    signal output commitment[numcommitments][n+1][N];

    component computeVote = computeBordaTournamentStyleBallot(nVotes, a, b);
    computeVote.ranking <== ranking;
    vote <== computeVote.out;

    for (var j=0; j< numcommitments; j++){
        for (var i=0; i<N; i++){
            if (j*N+i < nVotes){
                    message[j][i] <== vote[j*N+i];
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
}