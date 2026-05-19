pragma circom 2.2.1;

include "../utilities/arithmetic.circom";
include "../utilities/asserts.circom";
include "../../libs/node_modules/circomlib/circuits/comparators.circom";
include "../../libs/node_modules/circomlib/circuits/gates.circom";
include "util.circom";


/**
* Computes the corresponding Condorcet ballot to the ranking. (Since the values on the diagonal have no function, we assume, that those are zero.)
* maxValue is the maximal Value any entry in the ranking should have.
*/
template computeCondorcetBallot(nVotes, nBits) {
    input signal ranking[nVotes];

    output signal out[nVotes][nVotes]; // ballot

    component rankedWorse[nVotes][nVotes];
    component rankedTheSame[nVotes][nVotes];
    component computeEntryIJ[nVotes][nVotes];
    component computeEntryJI[nVotes][nVotes];
    signal tmp[nVotes][nVotes];

    var test = numBits(nVotes);

    for(var i = 0; i < nVotes; i++) {
        for(var j = i; j < nVotes; j++) {
            if(j == i) {
                out[i][j] <== 0;
            } else{
                rankedWorse[i][j] = GreaterThan(nBits); //r_i > r_j implies that i is ranked worse than j.
                rankedTheSame[i][j] = IsEqual(); // r_i = r_j implies that i and ja are ranked the same.
                computeEntryIJ[i][j] = switchCase(3);
                computeEntryJI[i][j] = switchCase(3);

                rankedWorse[i][j].in[0] <== ranking[i];
                rankedWorse[i][j].in[1] <== ranking[j];
                rankedTheSame[i][j].in[0] <== ranking[i];
                rankedTheSame[i][j].in[1] <== ranking[j];

                // tmp[i][j] <== 1 - rankedWorse[i][j].out;

                computeEntryIJ[i][j].cond[0] <== rankedWorse[i][j].out;
                computeEntryIJ[i][j].cond[1] <== rankedTheSame[i][j].out;
                // computeEntryIJ[i][j].s[2] <== tmp[i][j] * (1-rankedTheSame[i][j].out);
                computeEntryIJ[i][j].in[0] <== 0; // a_ij = 0 if i is ranked worse than j
                computeEntryIJ[i][j].in[1] <== 0; // a_ij = 0 if i is ranked the same as j
                computeEntryIJ[i][j].in[2] <== 1; // a_ij = 1 if i is ranked better than j
                out[i][j] <== computeEntryIJ[i][j].out;

                computeEntryJI[i][j].cond[0] <== rankedWorse[i][j].out;
                computeEntryJI[i][j].cond[1] <== rankedTheSame[i][j].out;
                // computeEntryJI[i][j].s[2] <== tmp[i][j] * (1-rankedTheSame[i][j].out);
                computeEntryJI[i][j].in[0] <== 1; // a_ji = 1 if i is ranked worse than j
                computeEntryJI[i][j].in[1] <== 0; // a_ji = 0 if i is ranked the same as j
                computeEntryJI[i][j].in[2] <== 0; // a_ji = 0 if i is ranked better than j
                out[j][i] <== computeEntryJI[i][j].out;
            }
        }
    }
}

