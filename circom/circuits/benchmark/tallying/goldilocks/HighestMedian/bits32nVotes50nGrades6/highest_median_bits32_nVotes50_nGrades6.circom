pragma circom 2.2.2;

include "../../../../../src/fullresultcircuit/snarkfield/majority_judgement/highest_median.circom";

template testMain(){
    var bits=32;
    var nVotes=50;
    var nGrades=6;
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
    var numcommitments = (nVotes * nGrades \ N) +1;
    signal input message[numcommitments][N];
    signal input randomness[numcommitments][k][N];
    signal output commitment[numcommitments][n+1][N];
    signal output winnerIdx[nVotes];

    component test = testMajorityJudgmentTally(bits, nVotes, nGrades, N, n, k, comkey);
    test.message <== message;
    test.randomness <== randomness;
    commitment <== test.commitment;
    winnerIdx <== test.winnerIdx;
}

component main = testMain();
