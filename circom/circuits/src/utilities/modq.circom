pragma circom 2.2.2;

include "../../libs/node_modules/circomlib/circuits/comparators.circom";

template elementModuloQBounded(q,qbits,bound,boundbits){
    // Takes an element of the snark field Fp and maps it to the lattice field Fq (q<p)
    // Requires bound to be at most 1 less than snark field size
    // Requires the input element to be bounded by bound - q (when represented in the snark field)
    // qbits = ceil(log2(q)), boundbits = ceil(log2(bound))
    input signal in;
    signal quotient;
    signal aux0;
    signal aux1;
    signal output out;
    component lt = LessThan(qbits);
    component lt_bound = LessThan(boundbits);

    quotient <-- in \ q;
    out <-- in - q*quotient; // standard representative in [0,q-1]

    in === quotient * q + out; // enforce the modulo constraint

    var bound_check = bound\q - 1;
    lt_bound.in[0] <== quotient;
    lt_bound.in[1] <== bound_check;
    aux0 <== lt_bound.out; // enforce that (quotient+1)*q is in [0,bound-1]
    aux0 === 1;
    
    lt.in[0] <== out; // enforce that out is in [0,q-1]
    lt.in[1] <== q;
    aux1 <== lt.out;
    aux1 === 1;
}

template elementModuloQBoundedSymmetric(q,qbits,bound,boundbits){
    // Takes an element of the snark field and maps it to the lattice field Fq, q an odd prime
    // Requires the input element to be bounded by bound (when represented in the snark field), should be at most 1 less than snark field size
    // qbits = ceil(log2(q)), boundbits = ceil(log2(bound))
    // uses a symmetric representative in [-(q-1)/2,...,(q-1)/2]
    input signal in;
    signal quotient;
    signal aux0;
    signal aux1;
    signal aux2;
    signal aux3;
    signal  remainder;
    signal output out;
    component leq = LessEqThan(qbits);
    component lt = LessThan(qbits);
    component lt_bound = LessThan(boundbits);

    quotient <-- in \ q;
    // remainder <-- in % q; // buggy
    remainder <-- in - q*quotient; // standard representative in [0,q-1]

    in === quotient * q + remainder; // enforce the modulo constraint

    var bound_check = bound\q +1;
    lt_bound.in[0] <== quotient;
    lt_bound.in[1] <== bound_check;
    aux0 <== lt_bound.out; // enforce that quotient is in [0,bound/q+1]
    aux0 === 1;
    
    lt.in[0] <== remainder; // enforce that remainder is in [0,q-1]
    lt.in[1] <== q;
    aux1 <== lt.out;
    aux1 === 1;

    leq.in[0] <== remainder;
    leq.in[1] <== (q-1)\2;
    aux2 <== leq.out*remainder;
    aux3 <== (1-leq.out)*(remainder-q);
    out <== aux2 + aux3; // representative in [-(q-1)/2,...,(q-1)/2]
}