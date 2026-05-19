pragma circom 2.2.1;
include "../../../crypto/commitment.circom";
include "../../../tallying/irv/evaluate_election_nsw_tie_breaker.circom";

template MERGED_Evaluate_election_nsw_tie_breaker(bitsVotes, getCandRemovedPos, getFirstRankedPos, nCand, nRankings, nRounds,N,n,k,comkey){
/**
 * Computes a commitment to an IRV tally and the associated election result.
 *   - bitsVotes: number of bits for tally entries, should be at least ceil(log2(#Voters * highest assignable value))
 *   - getCandRemovedPos: auxiliary constant mapping, indicates how rankings are adapted after candidate elimination
 *   - getFirstRankedPos: auxiliary constant mapping, indicates rankings in which a given candidate is ranked first
 *   - nCand: number of choices/canidates.
 *   - nRounds: maximal number of IRV rounds to run (for complete IRV evaluation, set nRounds=nCand-1)
 *   - nRankings: number of rankings, including partial (=length of tally)
 *
 *   Commitment parameters:
 *   - N: degree of the cyclotomic polynomial.
 *   - n: commitment dimension - 1 (del Pino d)
 *   - k: randomness dimension (del Pino 2d+1)
 *   - comkey[n+1][k][N]: (n+1)xk matrix of degree-N-polynomials in Zq[X]
 */
    var numcommitments = (nRankings \ N) +1;
    input signal tally[nRankings];
    signal message[numcommitments][N]; // // committed message (= tally split into chunks of size N)
    input signal tie_breaker_lots[nRounds][nCand]; // Lots for applying tie-breaking
    signal input randomness[numcommitments][k][N];
    signal output commitment[numcommitments][n+1][N];
    output signal out_Evaluate_election_nsw_tie_breaker[1][nCand];

    for (var j=0; j< numcommitments; j++){
        for (var i=0; i<N; i++){
            var msgidx = j*N+i;
            if (msgidx<nRankings){
              message[j][i]<== tally[msgidx];
            }
            else{
              message[j][i]<==0;
            }      
        }
    }

    component computeCommitment[numcommitments];
    for (var j=0; j< numcommitments; j++){
        computeCommitment[j] = commitSnarkField(comkey,N,n,k);
        computeCommitment[j].x <== message[j];
        computeCommitment[j].r <== randomness[j];
        commitment[j] <== computeCommitment[j].commitment;
    }

    component Evaluate_election_nsw_tie_breaker[1];

    for (var i_0 = 0; i_0 < 1; i_0++) {
      Evaluate_election_nsw_tie_breaker[i_0] = Evaluate_election_nsw_tie_breaker(nCand, nRounds, bitsVotes, nRankings, getCandRemovedPos, getFirstRankedPos);
      Evaluate_election_nsw_tie_breaker[i_0].tally <== tally;
      Evaluate_election_nsw_tie_breaker[i_0].tie_breaker_lots <== tie_breaker_lots;
      out_Evaluate_election_nsw_tie_breaker[i_0] <== Evaluate_election_nsw_tie_breaker[i_0].out;
    }
}
