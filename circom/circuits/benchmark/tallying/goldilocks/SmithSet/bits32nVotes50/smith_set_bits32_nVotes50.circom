pragma circom 2.2.2;

include "../../../../../src/fullresultcircuit/snarkfield/condorcet/smith_set.circom";

template testMain(){
    var bits=32;
    var nVotes=50;
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
    var numcommitments = (nVotes*nVotes \ N) +1;
    signal input tally[nVotes][nVotes];
    signal input randomness[numcommitments][k][N];
    signal output commitment[numcommitments][n+1][N];
    signal output smithSet[nVotes];

    component test = testCondorcetSmithSet(bits, nVotes, N, n, k, comkey);
    test.tally <== tally;
    test.randomness <== randomness;
    commitment <== test.commitment;
    smithSet <== test.smithSet;
}

component main = testMain();
