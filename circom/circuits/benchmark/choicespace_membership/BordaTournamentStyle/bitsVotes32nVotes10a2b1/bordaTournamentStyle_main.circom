pragma circom 2.2.2;

include "../../../../src/voting/bordaTournamentStyle.circom";

template testMain(){
    var nVotes=10;
    var a=2;
    var b=1;
    input signal ranking[nVotes];
    output signal out[nVotes];

    component test = computeBordaTournamentStyleBallot(nVotes, a, b);
    test.ranking <== ranking;
    out <== test.out;
}

component main = testMain();
