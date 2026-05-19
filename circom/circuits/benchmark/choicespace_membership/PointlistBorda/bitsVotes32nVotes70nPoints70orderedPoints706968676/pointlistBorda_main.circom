pragma circom 2.2.2;

include "../../../../src/voting/pointlistBorda.circom";

template testMain(){
    var bitsVotes=32;
    var nVotes=70;
    var nPoints=70;
    var orderedPoints[70] = [70, 69, 68, 67, 66, 65, 64, 63, 62, 61, 60, 59, 58, 57, 56, 55, 54, 53, 52, 51, 50, 49, 48, 47, 46, 45, 44, 43, 42, 41, 40, 39, 38, 37, 36, 35, 34, 33, 32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1];
    input signal ballot[nVotes];

    component test = assertPointlistBordaVoting(bitsVotes, nVotes, nPoints, orderedPoints);
    test.ballot <== ballot;
}

component main = testMain();
