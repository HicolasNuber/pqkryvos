pragma circom 2.2.2;

include "../../../../src/voting/multiVote.circom";

template testMain(){
    var bitsVotes=32;
    var nVotes=430;
    var maxVotesCand=4294957295;
    var maxChoices=4294957295;
    input signal ballot[nVotes];

    component test = assertMultiVoteVoting(bitsVotes, nVotes, maxVotesCand, maxChoices);
    test.ballot <== ballot;
}

component main = testMain();
