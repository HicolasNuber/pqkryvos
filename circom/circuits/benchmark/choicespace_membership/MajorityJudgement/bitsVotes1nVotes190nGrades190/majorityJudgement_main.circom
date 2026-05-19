pragma circom 2.2.2;

include "../../../../src/voting/majorityJudgement.circom";

template testMain(){
    var bitsVotes=1;
    var nVotes=190;
    var nGrades=190;
    input signal ballot[nVotes][nGrades];

    component test = assertMajorityJudgementVoting(bitsVotes, nVotes, nGrades);
    test.ballot <== ballot;
}

component main = testMain();
