pragma circom 2.2.1;

include "../utilities/arithmetic.circom";
include "../../libs/node_modules/circomlib/circuits/comparators.circom";
include "util.circom";

/**
* Given: A ranking of length nVotes and the points a and b to be given to each candidate for every candidate ranked worse/ equal than the current one.
* The template then computes the according ballot. The maximum value any entry in the ranking can have is nVotes. (Entries that are at most nVotes are enpugh to produce all possible rankings of nVotes candidates.)
*/
template computeBordaTournamentStyleBallot(nVotes, a, b) {
    input signal ranking[nVotes];

    output signal out[nVotes]; // ballot

    component rankedWorse[nVotes];
    component rankedTheSame[nVotes];
    component getAccordingPoints[nVotes];

    signal rankedWorsePoints[nVotes];
    signal rankedTheSamePoints[nVotes];

    for(var i = 0; i < nVotes; i++) {
        rankedWorse[i] = countGreater(nVotes);
        rankedTheSame[i] = countEqual(nVotes);

        rankedWorse[i].in <== ranking;
        rankedWorse[i].test <== ranking[i];

        rankedTheSame[i].in <== ranking;
        rankedTheSame[i].test <== ranking[i];

        rankedWorsePoints[i] <== a * rankedWorse[i].out;
        rankedTheSamePoints[i] <== b * (rankedTheSame[i].out - 1); // (... -1) to exclude the entry at position i

        out[i] <== rankedWorsePoints[i] + rankedTheSamePoints[i];
    }
}
