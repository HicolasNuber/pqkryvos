pragma circom 2.2.2;

include "../../../../src/voting/pointlistBorda.circom";

template testMain(){
    var bitsVotes=32;
    var nVotes=30;
    var nPoints=30;
    var orderedPoints[30] = [30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1];
    input signal ballot[nVotes];

    component test = assertPointlistBordaVoting(bitsVotes, nVotes, nPoints, orderedPoints);
    test.ballot <== ballot;
}

component main = testMain();
