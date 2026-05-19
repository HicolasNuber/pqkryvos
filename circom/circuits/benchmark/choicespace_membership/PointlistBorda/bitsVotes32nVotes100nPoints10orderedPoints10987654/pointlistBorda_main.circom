pragma circom 2.2.2;

include "../../../../src/voting/pointlistBorda.circom";

template testMain(){
    var bitsVotes=32;
    var nVotes=100;
    var nPoints=10;
    var orderedPoints[10] = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1];
    input signal ballot[nVotes];

    component test = assertPointlistBordaVoting(bitsVotes, nVotes, nPoints, orderedPoints);
    test.ballot <== ballot;
}

component main = testMain();
