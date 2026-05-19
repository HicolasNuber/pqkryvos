pragma circom 2.2.2;

include "../../crypto/commitment.circom";
include "../../voting/majorityJudgement.circom";

template computeMajorityJudgementCompleteLattice(bitsVotes,nVotes,nGrades,N,q,n,k,comkey){
/**
 * Computes a commitment to a Majority Judgement Vote, assuming SNARK field != Lattice Field.
 *
 *   Vote parameters:
 *   - nVotes: number of choices/candidates.
 *   - nGrades: number of assignable grades
 *
 *   Commitment parameters:
 *   - N: degree of the cyclotomic polynomial.
 *   - q: prime modulus < SNARK field modulus
 *   - n: commitment dimension - 1 (del Pino d)
 *   - k: randomness dimension (del Pino 2d+1)
 *   - comkey[n+1][k][N]: (n+1)xk matrix of degree-N-polynomials in Zq[X]
 */
    var matrixEntries = nVotes * nGrades; // Majority Judgement Vote is (nVotes x nGrades) matrix; we roll out row-wise
    var numcommitments = (nVotes * nGrades \ N) +1;
    
    signal input message[numcommitments][N];
    signal input randomness[numcommitments][k][N];
    signal output commitment[numcommitments][n+1][N];
    
    component computeCommitment[numcommitments];
    for (var i=0; i< numcommitments; i++){
        computeCommitment[i] = commit(comkey,N,n,k,q);
        computeCommitment[i].x <== message[i];
        computeCommitment[i].r <== randomness[i];
        commitment[i] <== computeCommitment[i].commitment;
    }

    component testMajorityJudgement = assertMajorityJudgementVoting(1, nVotes, nGrades);

    for (var j=0;j<numcommitments;j++){
        for (var i=0;i<N; i++){
            var msgidx = j*N+i;
            if(msgidx < matrixEntries){
            var rowidx = msgidx \ nGrades; 
            var colidx = msgidx % nGrades;
                testMajorityJudgement.ballot[rowidx][colidx] <== message[j][i];
            }
        }
    }
}