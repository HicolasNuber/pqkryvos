pragma circom 2.2.2;

include "../../../../../src/fullballotvaliditycircuit/snarkfield/condorcetComplete.circom";

template testMain(){
    var nBits=5;
    var nVotes=2;
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
    signal input ranking[nVotes];
    signal input randomness[numcommitments][k][N];
    signal output commitment[numcommitments][n+1][N];

    component test = computeCondorcetComplete(bitsVotes, nVotes, N, n, k, comkey);
    test.ranking <== ranking;
    test.randomness <== randomness;
    commitment <== test.commitment;
}

component main = testMain();
