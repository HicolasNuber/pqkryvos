pragma circom 2.2.2;

include "../../../../src/voting/condorcet.circom";

template testMain(){
    var nVotes=12;
    var nBits=5;
    input signal ranking[nVotes];
    output signal out[nVotes][nVotes];

    component test = computeCondorcetBallot(nVotes, nBits);
    test.ranking <== ranking;
    out <== test.out;
}

component main = testMain();
