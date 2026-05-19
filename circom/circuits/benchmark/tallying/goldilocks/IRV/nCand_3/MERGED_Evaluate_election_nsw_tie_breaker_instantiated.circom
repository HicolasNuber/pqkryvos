pragma circom 2.2.1;

include "../../../../../src/fullresultcircuit/snarkfield/irv/MERGED_Evaluate_election_nsw_tie_breaker.circom";

template testMain(nCand,nRankings,nRounds){
    var N=486;
    var n=6;
    var k=13;
    var comkey[n+1][k][N];

    for (var i=0; i<n+1; i++) {
        for (var j=0; j<k; j++) {
            for (var s=0; s<N; s++) {
                comkey[i][j][s]=2; // default placeholder
            }
        }
    }
    var numcommitments = (nRankings \ N) +1;

    signal input tally[nRankings];
    input signal tie_breaker_lots[nRounds][nCand];
    signal input randomness[numcommitments][k][N];
    signal output commitment[numcommitments][n+1][N];
    output signal out_Evaluate_election_nsw_tie_breaker[1][nCand];

    component test = MERGED_Evaluate_election_nsw_tie_breaker(32, [[0,0,0],[0,1,1],[6,1,2],[9,4,2],[11,4,1],[14,4,2],[6,0,6],[6,1,7],[9,4,7],[9,11,6],[9,12,7],[11,11,0],[11,12,1],[14,12,2],[14,11,6],[14,12,7]], [[1,2,3,4,5],[6,7,8,9,10],[11,12,13,14,15]], nCand, nRankings, nRounds,N,n,k,comkey);

    test.tally <== tally;
    test.tie_breaker_lots <== tie_breaker_lots;
    test.randomness <== randomness;
    commitment <== test.commitment;
    out_Evaluate_election_nsw_tie_breaker <== test.out_Evaluate_election_nsw_tie_breaker;

}

component main = testMain(3,16,3);