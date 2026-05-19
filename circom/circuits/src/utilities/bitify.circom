pragma circom 2.2.1;
include "arithmetic.circom";
include "branching.circom";
include "asserts.circom";
include "../../libs/node_modules/circomlib/circuits/bitify.circom";
include "../../libs/node_modules/circomlib/circuits/comparators.circom";

/**
* Converts the number in to binary representation (LSB) and padds the representation with 2 to extend it to length n.
* Note, the first Non-zero bit from the end of the binary representation will also be set to 2. 
* This is needed for the montgomery scalar multiplication.
*/
template num2BitsPadded(n) {
    input signal in;

    output signal out[n];

    component toBits = Num2Bits(n);
    toBits.in <== in;
    signal inBits[n] <== toBits.out;

    component padBits = padBits(n);
    padBits.in <== inBits;
    out <== padBits.out;
}

/**
* For a number in to binary representation (LSB): Padds the representation with 2 to extend it to length n.
* Note, the first Non-zero bit from the end of the binary representation will also be set to 2. 
* This is needed for the montgomery scalar multiplication (in one of the implemented options).
*/
template padBits(n) {
    input signal in[n];

    output signal out[n];

    component setPadding[n];
    component needsPadding[n];

    signal sumBits[n+1];
    sumBits[n] <== 0;
    for(var i = n-1; i >= 0; i--) {
        sumBits[i] <== sumBits[i+1] + in[i];

        setPadding[i] = ifThenElse();
        needsPadding[i] = IsZero();

        needsPadding[i].in <== sumBits[i+1]; //First Non-zero Bit is also set to 2.

        setPadding[i].ifV <== 2; //Padding 2 for trailing zeros.
        setPadding[i].elseV <== in[i];
        setPadding[i].cond <== needsPadding[i].out;

        out[i] <== setPadding[i].out;
    }  
}

/**
* Asserts that a given input is the same as the input given in array-index representation in the given base with digits many digits.
*
*   in_indices = [[in_indices_0_0, in_indices_0_1, ..., in_indices_0_(base-1)], [in_indices_1_0, in_indices_1_1, ..., in_indices_1_(base-1)], ..., [in_indices_(digits-1)_0, in_indices_(digits-1)_1, ..., in_indices_(digits-1)_(base-1)]] 
*   with in = (in_indices[0][0] * 0 * base^0 + in_indices[0][1] * 1* base^0 + ... + in_indices[0][base-1] * (base-1) * base^0) 
                + (in_indices[1][0] * 0 * base^1 + in_indices[1][1] * 1* base^1 + ... + in_indices[1][base-1] * (base-1) * base^1) 
                + ... 
                + (in_indices[digits-1][0] * 0 * base^(digits-1) + in_indices[digits-1][1] * 1* base^(digits-1) + ... + in_indices[digits-1][base-1] * (base-1) * base^(digits-1))
*/
template assert_base_indices(base, digits) {
    input signal in;
    input signal in_indices[digits][base];

    component assert_entries_bits[digits][base];
    var test = 0;
    var base_power = 1;
    for(var i = 0; i < digits; i++) {
        var digit_index_sum = 0;
        for(var j = 0; j < base; j++) {
            assert_entries_bits[i][j] = assertBit();
            assert_entries_bits[i][j].in <== in_indices[i][j];
            test += in_indices[i][j] * j * base_power;
            digit_index_sum += in_indices[i][j];
        }
        digit_index_sum === 1; // Exactly one index must be 1 per digit in array-index representation.
        base_power *= base;
    }

    in === test;
}