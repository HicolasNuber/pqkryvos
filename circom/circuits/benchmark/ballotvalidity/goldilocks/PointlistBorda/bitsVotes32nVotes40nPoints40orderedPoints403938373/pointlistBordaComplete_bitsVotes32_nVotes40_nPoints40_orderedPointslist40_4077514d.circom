pragma circom 2.2.2;

include "../../../../../src/fullballotvaliditycircuit/snarkfield/pointlistBordaComplete.circom";

template testMain(){
    var bitsVotes=32;
    var nVotes=40;
    var nPoints=40;
    var orderedPoints[40] = [40, 39, 38, 37, 36, 35, 34, 33, 32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1];
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

    component test = computePointlistBordaComplete(bitsVotes, nVotes, nPoints, orderedPoints, N, n, k, comkey);
    test.message <== message;
    test.randomness <== randomness;
    commitment <== test.commitment;
}

component main = testMain();
