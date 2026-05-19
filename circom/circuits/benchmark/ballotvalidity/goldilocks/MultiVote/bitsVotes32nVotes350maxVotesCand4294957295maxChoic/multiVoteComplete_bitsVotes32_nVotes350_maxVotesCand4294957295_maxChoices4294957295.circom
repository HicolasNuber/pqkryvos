pragma circom 2.2.2;

include "../../../../../src/fullballotvaliditycircuit/snarkfield/multiVoteComplete.circom";

template testMain(){
    var bitsVotes=32;
    var nVotes=350;
    var maxVotesCand=4294957295;
    var maxChoices=4294957295;
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
    var numcommitments = (nVotes \ N) +1;
    signal input message[numcommitments][N];
    signal input randomness[numcommitments][k][N];
    signal output commitment[numcommitments][n+1][N];

    component test = computeMultiVoteComplete(bitsVotes, nVotes, maxVotesCand, maxChoices, N, n, k, comkey);
    test.message <== message;
    test.randomness <== randomness;
    commitment <== test.commitment;
}

component main = testMain();
