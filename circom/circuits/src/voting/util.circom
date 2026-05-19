pragma circom 2.2.1;

include "../utilities/arithmetic.circom";
include "../utilities/asserts.circom";
include "../../libs/node_modules/circomlib/circuits/comparators.circom";
include "../../libs/node_modules/circomlib/circuits/gates.circom";

/**
* Counts the elements in the array that are greater than test.
* The max allowed value in in is n.
*/
template countGreater(n) {
    input signal in[n];
    input signal test;

    output signal out;

    component isGreater[n];
    var counter = 0;
    var maxValueBits = numBits(n);

    for(var i = 0; i < n; i++) {
        isGreater[i] = GreaterThan(maxValueBits);
        isGreater[i].in[0] <== in[i];
        isGreater[i].in[1] <== test;
        counter += isGreater[i].out;
    }

    out <== counter;
}

/**
* Counts the elements in the array that are equal to test.
*/
template countEqual(n) {
    input signal in[n];
    input signal test;

    output signal out;

    component isEqual[n];

    var counter = 0;

    for(var i = 0; i < n; i++) {
        isEqual[i] = IsEqual();
        isEqual[i].in[0] <== in[i];
        isEqual[i].in[1] <== test;
        counter += isEqual[i].out;
    }

    out <== counter;
}

/**
* Computes, how often choice occurs in a list of values valuesList of length n.
*/
template getOccurences(n) {
    input signal choice;
    input signal valuesList[n];

    output signal out;

    var counter = 0;
    component comparators[n];

    for(var i = 0; i < n; i++) {
        comparators[i] = IsEqual();
        comparators[i].in[0] <== choice;
        comparators[i].in[1] <== valuesList[i];

        counter += comparators[i].out;
    }

    out <== counter;
}