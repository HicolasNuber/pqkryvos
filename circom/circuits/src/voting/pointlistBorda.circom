pragma circom 2.2.1;

include "../utilities/asserts.circom";
include "../../libs/node_modules/circomlib/circuits/comparators.circom";
include "util.circom";


/**
* Asserts a Borda ballot.
* If nVotes > nPoints, we assume, that the pointlist is padded with (nVotes - nPoints) zeros.
* orderedPoints is the list of points (descending order) and has length m.
*/
template assertPointlistBordaVoting(bitsVotes, nVotes, nPoints, orderedPoints) {
    input signal ballot[nVotes];

    signal expectedZeros <== nVotes - nPoints;
    component getOccurencesZero = getOccurences(nVotes);
    getOccurencesZero.choice <== 0;
    getOccurencesZero.valuesList <== ballot;
    signal numZeros <== getOccurencesZero.out;
    numZeros === expectedZeros;

    component getOccurences[nPoints];

    for(var i = 0; i < nPoints; i++) {
        getOccurences[i] = getOccurences(nVotes);
        getOccurences[i].choice <== orderedPoints[i];
        getOccurences[i].valuesList <== ballot;

        getOccurences[i].out === 1;
    }
}
