pragma circom 2.2.1;

include "singleVote.circom";
include "../utilities/arithmetic.circom";
include "../utilities/asserts.circom";
include "../../libs/node_modules/circomlib/circuits/comparators.circom";
include "../../libs/node_modules/circomlib/circuits/gates.circom";

/**
* Checks that a given ballot conforms to the Majority Judgement Election type.
* nVotes is the number of Candidates and nGrades is the number of grades.
* For each candidate (rows in the ballot matrix) exactly one of the grades should be set (entry is 1) and the others should be 0.
*/
template assertMajorityJudgementVoting(bitsVotes, nVotes, nGrades) {
    input signal ballot[nVotes][nGrades];

    component assertBit[nVotes][nGrades];

    for(var i = 0; i < nVotes; i++) {
        var sum = 0;
        for(var j = 0; j < nGrades; j++) {
            assertBit[i][j] = assertBit();
            assertBit[i][j].in <== ballot[i][j];
            sum += ballot[i][j];
        }
        sum === 1;
    }
}