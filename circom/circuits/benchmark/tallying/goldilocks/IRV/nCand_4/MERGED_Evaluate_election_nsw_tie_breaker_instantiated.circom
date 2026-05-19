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

    component test = MERGED_Evaluate_election_nsw_tie_breaker(32, [[0,0,0,0],[0,1,1,1],[17,1,2,2],[23,7,2,3],[26,10,5,3],[28,12,5,2],[31,15,5,3],[33,7,1,7],[39,7,2,8],[42,10,5,8],[44,10,12,7],[47,10,13,8],[49,12,12,1],[55,12,13,2],[58,15,13,3],[60,15,12,7],[63,15,13,8],[17,0,17,17],[17,1,18,18],[23,7,18,19],[26,10,21,19],[28,12,21,18],[31,15,21,19],[23,33,17,23],[23,34,18,24],[26,37,21,24],[26,44,28,23],[26,45,29,24],[28,49,28,17],[28,50,29,18],[31,53,29,19],[31,60,28,23],[31,61,29,24],[33,33,0,33],[33,34,1,34],[39,34,2,35],[42,37,5,35],[44,37,12,34],[47,37,13,35],[39,33,17,39],[39,34,18,40],[42,37,21,40],[42,44,28,39],[42,45,29,40],[44,44,49,33],[44,45,50,34],[47,45,51,35],[47,44,55,39],[47,45,56,40],[49,49,49,0],[49,50,50,1],[55,50,51,2],[58,53,51,3],[60,53,50,7],[63,53,51,8],[55,49,55,17],[55,50,56,18],[58,53,56,19],[58,60,55,23],[58,61,56,24],[60,60,49,33],[60,61,50,34],[63,61,51,35],[63,60,55,39],[63,61,56,40]], [[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],[17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32],[33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48],[49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64]], nCand, nRankings, nRounds,N,n,k,comkey);

    test.tally <== tally;
    test.tie_breaker_lots <== tie_breaker_lots;
    test.randomness <== randomness;
    commitment <== test.commitment;
    out_Evaluate_election_nsw_tie_breaker <== test.out_Evaluate_election_nsw_tie_breaker;

}

component main = testMain(4, 65, 4);