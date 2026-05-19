pragma circom 2.2.1;

include "../../libs/node_modules/circomlib/circuits/comparators.circom";
include "../../libs/node_modules/circomlib/circuits/gates.circom";
include "../utilities/listGates.circom";

/**
* Compute the Smith Set for the given tally. The Smith Set is the smallest set of elements from the tally such that every element in the set is higher than every element outside of the set.
* The output is an index list indicating whether an element is in the Smith Set or not. tally[i][j] = m, iff m voters prefer candidate i over candidate j.
* bits is the maximum number of bits needed to represent an entry in tally.
* 
* O(n^3) constraints
*/ 
template computeSmithSet(n, bits) {
    input signal tally[n][n];

    output signal out[n];

    signal isGreater[n][n]; // isGreater[i][j] = 1, iff tally[i][j] > tally[j][i] (More Voters prefer i over j than j over i)
    signal wonMatches[n]; // wonMatches[i] = m, iff there are m positions j, for which isGreater[i][j] = 1.
    component comp[n][n]; 

    for (var i = 0; i < n; i++){
        var winCount = 0;
        for (var j = 0; j < n; j++){
            if (i != j) {
                comp[i][j] = GreaterThan(bits);
                comp[i][j].in[0] <== tally[i][j];
                comp[i][j].in[1] <== tally[j][i];

                isGreater[i][j] <== comp[i][j].out;
                winCount += isGreater[i][j];
            }
        }
        wonMatches[i] <== winCount;
    }

    signal mostWonMatches[n];
    component maxima = computeMaximumIndicator(n, bits);
    maxima.tally <== wonMatches;

    signal runningSmithSet[n][n];
    runningSmithSet[0] <== maxima.indices;
    component isZero[n][n];
    component and[n][n][n];
    for (var i = 1; i < n; i++){
        for (var j = 0; j < n; j++) {
            var smithIndSum = 0;
            for (var k = 0; k < n; k++) {
                if (k != j) {
                    and[i][j][k] = AND();
                    and[i][j][k].a <== isGreater[j][k]; // j wins over k
                    and[i][j][k].b <== runningSmithSet[i-1][k]; // k is in smith set
                    smithIndSum += and[i][j][k].out; // --> j should be in the smith set
                }
            }
            isZero[i][j] = IsZero();
            isZero[i][j].in <== smithIndSum;
            runningSmithSet[i][j] <== 1 - isZero[i][j].out;
        }
    }
}

/**
* Computes the winner of a majority judgement election.
*/
template computeMajorityJudgement(n_cand, n_grades, bits) {
    input signal tally[n_cand][n_grades];

    output signal winnerIdx[n_cand]; // winnerIdx[i]=1, if the candidate at position i won.

    signal runningWinnerIdx[n_cand][n_cand];
    signal runningTally[n_cand + 1][n_cand][n_grades];
    runningTally[0] <== tally;

    // Step 1
    component getMedian[n_cand][n_cand];
    signal median[n_cand][n_cand];

    // Step 2
    component getBestMedian[n_cand];
    signal bestMedian[n_cand];

    // Step 3
    component getBestMedianFilter[n_cand];
    signal bestMedianFilter[n_cand][n_grades];

    // Step 4
    component idxBestMedian[n_cand];

    // Step 5
    signal occurencesBestMedian[n_cand][n_cand];
    signal sum[n_cand][n_cand][n_grades + 1];
    signal tmp[n_cand][n_cand][n_grades];
    component getMinOccurenceBestMedian[n_cand];
    signal minOccurenceBestMedian[n_cand];

    // Step 6
    signal modifiedTally[n_cand][n_cand][n_grades];
    component subtractMinOccurenceBestMedian[n_cand][n_cand];

    // Step 7
    component applyFilterToTally[n_cand];

    for (var round = 0;round < n_cand; round++) {// One candidate gets eliminated in each round.
        // Step 1: Compute median grade for each candidate. (Filtered out candidates will be assigned the highest possbile median.)
        for (var i = 0; i < n_cand; i++) {
            getMedian[round][i] = getIndexMedian(n_grades, bits);
            getMedian[round][i].in <== runningTally[round][i];
            median[round][i] <== getMedian[round][i].out;
        }

        // Step 2: Find the best (lowest) median grade
        getBestMedian[round] = minValue(n_cand, bits);
        getBestMedian[round].in <== median[round];
        bestMedian[round] <== getBestMedian[round].out;

        // Step 3: Mark the index of the best median
        getBestMedianFilter[round] = idxPosition(n_grades);
        getBestMedianFilter[round].in <== bestMedian[round];
        bestMedianFilter[round] <== getBestMedianFilter[round].out;

        // Step 4: Mark the candidates that receive the best median grade (winning candidates)
        idxBestMedian[round] = idxEqual(n_cand);
        idxBestMedian[round].in <== median[round];
        idxBestMedian[round].test <== bestMedian[round]; // Creates a list of the candidates, marking each candidate receiving the best median grade (winning candidate) with 1 and every other candidate with 0.
        runningWinnerIdx[round] <== idxBestMedian[round].out;
        
        // Step 5: Find the minimum occurence of the best median among the candidates that received the best median grade (winning candidates)
        for (var i = 0; i < n_cand; i++) {
            sum[round][i][0] <== (1 - runningWinnerIdx[round][i]) * (-1); // Max possible value, if the candidate does not win.
            for (var j = 0; j < n_grades; j++) {
                tmp[round][i][j] <== runningWinnerIdx[round][i] * bestMedianFilter[round][j]; // Only keep the value, if it corresponds to the best median and the candidate is a winning candidate
                sum[round][i][j + 1] <== sum[round][i][j] + runningTally[round][i][j] * tmp[round][i][j];
            }
            occurencesBestMedian[round][i] <== sum[round][i][n_grades];
        }
        getMinOccurenceBestMedian[round] = minValue(n_cand, bits);
        getMinOccurenceBestMedian[round].in <== occurencesBestMedian[round];
        minOccurenceBestMedian[round] <== getMinOccurenceBestMedian[round].out;

        // Step 6: Deduct the minimum occurence of the best median at the position of the best median from the current tally
        // (No need to filter out the non winning candidates since their values will be set to zero in the next step anyway.)
        for (var i = 0; i < n_cand; i++) {
            subtractMinOccurenceBestMedian[round][i] = scalarAddAtIdx(n_grades);
            subtractMinOccurenceBestMedian[round][i].in <== runningTally[round][i];
            subtractMinOccurenceBestMedian[round][i].idx <== bestMedianFilter[round];
            subtractMinOccurenceBestMedian[round][i].scalar <== (-1) * minOccurenceBestMedian[round];
            modifiedTally[round][i] <== subtractMinOccurenceBestMedian[round][i].out;
        }

        // Step 7: Filter the candidates, keeping only the ones receiving the best median
        applyFilterToTally[round] = pairwiseMultMatrix(n_cand, n_grades);
        applyFilterToTally[round].in1 <== modifiedTally[round];
        for(var i = 0; i < n_cand; i++) {
            for(var j = 0; j < n_grades; j++) {
                applyFilterToTally[round].in2[i][j] <== runningWinnerIdx[round][i];
            }
        }
        runningTally[round + 1] <== applyFilterToTally[round].out;
    }
    winnerIdx <== runningWinnerIdx[n_cand - 1];
}

/**
* Computes the index representing the median of the aggregated values.
* I.e., [2,6,3,2,1,0] means that the value 0 occurs twice in the aggregated values, 1 occurs six times, ... and 5 occurs 0 times.
* Consequently, the median is 1 (<= 7 values are smaller and <= 7 values are larger with there being 14 values in total).
*
* Edge Case: Will return n-1 for an array [0,0,...,0].
*/
template getIndexMedian(n, bits) {
    input signal in[n];
    output signal out;

    signal sum_halve;
    component bit = assertBit();
    var sum = 0;
    for (var i = 0; i < n; i++) {
        sum += in[i];
    }
    sum_halve <-- sum / 2;
    bit.in <== sum_halve * 2 - sum;

    sum = 0;
    var idx = n-1;
    component less[n];
    for (var i = n-1; i >= 0; i--) {
        less[i] = LessThan(bits);
        sum += in[i];
        less[i].in[0] <== sum;
        less[i].in[1] <== sum_halve;
        idx -= less[i].out; // Subtract 1 from the index as long as the sum of all aggregated numbers of values so far is lower than half the total number of values.
    }
    out <== n-idx;
}