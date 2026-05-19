pragma circom 2.2.2;

include "../../../../src/voting/singleVote.circom";

template testMain(){
    var bitsVotes=1;
    var nVotes=200;
    input signal ballot[nVotes];

    component test = assertSingleVoteVoting(bitsVotes, nVotes);
    test.ballot <== ballot;
}

component main = testMain();
