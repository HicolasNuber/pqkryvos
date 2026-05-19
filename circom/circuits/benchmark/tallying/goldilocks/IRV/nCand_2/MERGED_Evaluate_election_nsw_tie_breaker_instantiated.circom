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

    component test = MERGED_Evaluate_election_nsw_tie_breaker(32, [[0,0],[0,1],[3,1],[3,0],[3,1]], [[1,2],[3,4]], nCand, nRankings, nRounds,N,n,k,comkey);

    test.tally <== tally;
    test.tie_breaker_lots <== tie_breaker_lots;
    test.randomness <== randomness;
    commitment <== test.commitment;
    out_Evaluate_election_nsw_tie_breaker <== test.out_Evaluate_election_nsw_tie_breaker;

}

component main = testMain(2,5,2);