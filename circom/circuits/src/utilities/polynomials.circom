pragma circom 2.2.2;

include "../../libs/node_modules/circomlib/circuits/comparators.circom";
include "modq.circom";

function log2(a) {
    if (a==0) {
        return 0;
    }
    var n = 1;
    var r = 1;
    while (n<a) {
        r++;
        n *= 2;
    }
    return r;
}

// Polynomials are encoded as coefficient vectors
// This file contains polynomial addition and multiplication, 
// Multiplication of polynomial matrix with vectors
// All operations are provided in the SNARK field and modulo
// a smaller field q


// ASSERT AND TAKE MOD Q //

template assertPolynomialEntriesModQ(N,q){
    // Checks that all N coefficients of P are in [0,q-1]
    var qbits =log2(q);
    input signal P[N];
    component lt[N];
    for (var s=0;s<N;s++){
        lt[s] = LessThan(qbits);
        lt[s].in[0] <== P[s];
        lt[s].in[1] <== q;
        lt[s].out === 1;
    }
}

template degreeNPolynomialModuloQ(N,q,bound){
    // Takes all coefficients of a degree-N-polynomial modulo q,q>1, odd
    // Representatives in [0,q-1] = Lattice Field
    // bound is the maximum value of the coefficients in the polynomial, should be at most 1 less than snark field size
    // Obsolete if SNARK field = Lattice Field
    var qbits = log2(q);
    var boundbits = log2(bound);
    input signal P[N];
    output signal result[N];
    component modQ[N];
    for (var i=0; i<N; i++){
        modQ[i] = elementModuloQBounded(q,qbits,bound,boundbits);
        modQ[i].in <== P[i];
        result[i] <== modQ[i].out;
    }
}

// ADDITION //

template addDegreeNPolynomials(N){
    // Add two degree-N-polynomials in Fp[X] where Fp is the SNARK field
    input signal P1[N];
    input signal P2[N];
    output signal result[N];

    for (var i=0; i<N; i++){
        result[i] <== P1[i]+P2[i];
    }
}

template addDegreeNPolynomialsModQ(N,q){
    // Add two polynomials in Fq[X]/(X^N+1), where Fq is the Lattice field
    // Obsolete if SNARK field = Lattice Field
    // Representatives in [0,q-1] = Lattice Field
    // NOTE: This is written under the assumption that the input polynomials are in Zq[X], i.e., the coefficients are in [0,q-1]. Should be combined with the assert from above
    input signal P1[N];
    input signal P2[N];
    output signal result[N];
    component modQ[N];

    for (var i=0; i<N; i++){
        var temp = P1[i] + P2[i];
        modQ[i] = elementModuloQBounded(q,log2(q),3*q,log2(3*q)+1);
        modQ[i].in <== temp;
        result[i] <== modQ[i].out;
    }
}

// MULTIPLICATION //

template multiplyDegreeNPolynomials(N){
    // Multiply two polynomials in Fp[X]/(X^N+1), where Fp is the SNARK field
    input signal P1[N];
    input signal P2[N];
    output signal result[N];
    signal t1s[N*(N+1)/2];
    signal t2s[N*(N-1)/2];
    var t1_idx=0;
    var t2_idx=0;

    for (var k=0; k<N; k++){ // assign k-th coefficient
        var acc = 0;
        for (var i=0; i<=k; i++){ // regular coefficients
            t1s[t1_idx] <== P1[i]*P2[k-i];
            acc += t1s[t1_idx];
            t1_idx += 1;
        }
        for (var i=k+1; i<N; i++){ // wrap-around coefficients
            t2s[t2_idx] <== P1[i]*P2[N+k-i];
            acc -= t2s[t2_idx];
            t2_idx += 1;
        }
        result[k] <== acc;
    }
}

template multiplyDegreeNPolynomialsModQ(N,q){
    // Multiply two polynomials in Fq[X]/(X^N+1), where Fq is the Lattice field
    // Obsolete if SNARK field = Lattice Field
    // Representatives in [0,q-1] = Lattice Field
    // NOTE: This is written under the assumption that the input polynomials are in Zq[X], i.e., the coefficients are in [0,q-1]. Should be combined with the assert from above
    var qbits = log2(q);
    input signal P1[N];
    input signal P2[N];
    output signal result[N];
    signal t1s[N*(N+1)/2];
    signal t2s[N*(N-1)/2];
    var t1_idx=0;
    var t2_idx=0;
    component modQ[N];

    for (var k=0; k<N; k++){ // assign k-th coefficient
        var acc = 0;
        for (var i=0; i<=k; i++){ // regular coefficients
            t1s[t1_idx] <== P1[i]*P2[k-i];
            acc += t1s[t1_idx];
            t1_idx += 1;
        }
        for (var i=k+1; i<N; i++){ // wrap-around coefficients
            t2s[t2_idx] <== q**2-P1[i]*P2[N+k-i];
            acc += t2s[t2_idx];
            t2_idx += 1;
        }
        // acc mod q is now the k-th coefficient of the product polynomial
        modQ[k] = elementModuloQBounded(q,qbits,N*q**2+q,log2(N*q**2+q)+1); //Might achieve a better bound if we require the input polynomials to be bounded
        modQ[k].in <== acc;
        result[k] <== modQ[k].out;
    }
}

template multiplyPublicPolynomialMatrixWithPolynomialVector(N,m,k){
    // Multiplies a public mxk Matrix over Rq with a vector in Rq^k
    // Here, Rq=Zq[X]/(X^N+1), Assumption: SNARK field = Lattice field
    var matrix[m][k][N];
    input signal vector[k][N];
    output signal result[m][N];
    // signal acc[m][k][N];
    component polymult[m][k];

    for (var i=0; i<m;i++){
        for (var j=0; j<k; j++){
            for (var s=0; s<N; s++){
                matrix[i][j][s]=2;
            }
        }
    }

    for (var i=0; i<m; i++){
        var temp[N];
        for (var j=0; j<k; j++){
            polymult[i][j]=multiplyDegreeNPolynomials(N);
            polymult[i][j].P1 <== matrix[i][j];
            polymult[i][j].P2 <== vector[j];
            for (var s=0; s<N; s++){
                temp[s]+=polymult[i][j].result[s];
            }
        }
        result[i] <== temp;
    }
}

template multiplyPolynomialMatrixWithPolynomialVectorModQ(N,m,k,q){
    // Multiplies an mxk Matrix over Rq with a vector in Rq^k
    // Obsolete if SNARK field = Lattice Field
    // Representatives in [0,q-1] = Lattice Field
    // qbits = ceil(log2(q))
    // NOTE: This is written under the assumption that the input polynomials are in Zq[X], i.e., the coefficients are in [0,q-1]
    input signal matrix[m][k][N];
    input signal vector[k][N];
    output signal result[m][N];
    signal acc[m][k][N];
    component polymult[m][k];
    component polyModQ[m];

    for (var i=0; i<m; i++){ //rows
        for (var j=0; j<k; j++){ //columns
            polymult[i][j]=multiplyDegreeNPolynomialsModQ(N,q);
            for (var s=0; s<N; s++){
                polymult[i][j].P1[s] <== matrix[i][j][s];
                polymult[i][j].P2[s] <== vector[j][s];
            }
            for (var s=0; s<N; s++){
                acc[i][j][s]<==polymult[i][j].result[s];
            }
        }
    }

    for (var i=0; i<m; i++){
        var temp[N];
        for (var s=0; s<N; s++){
            temp[s]=0; //Instantiate as zero polynomial
        }
        for (var s=0; s<N; s++){
            for (var j=0; j<k; j++){
                temp[s]+=acc[i][j][s]; // s-th coefficient of temp is sum of s-th coefficients of acc[i][0],...,acc[i][k-1]
            }
        }

        polyModQ[i]=degreeNPolynomialModuloQ(N,q,k*m*q+q);
        for (var s=0; s<N; s++){
            polyModQ[i].P[s] <== temp[s];
        }
        for (var s=0; s<N; s++){
            result[i][s] <== polyModQ[i].result[s];
        }
    }
}

template addPolyVectorWithZeroPadVector(N,m,num_messages){
    // Adds two length-m vectors over Fp[X]/(X^N+1) (Fp the SNARK field)
    // where the second vector starts with m-num_messages 0s followed
    // by num_messages arbitrary polynomials 
    // the second vector is only specified via its last num_messages entries.

    input signal in1[m][N];
    input signal in2[num_messages][N];
    output signal out[m][N];
    var n=m-num_messages;
    component addPolys[num_messages];

    for (var i=0; i<n;i++){
        for (var s=0; s<N; s++){
            out[i][s] <== in1[i][s];
        }
    }
    for (var i=n; i<m; i++){
        addPolys[n-i] = addDegreeNPolynomials(N);
        addPolys[n-i].P1 <== in1[i];
        addPolys[n-i].P2 <== in2[n-i];
        for (var s=0; s<N; s++){
            out[i][s] <== addPolys[n-i].result[s];
        }
    }

}

template addPolyVectorWithZeroPadVectorModQ(N,m,num_messages,q){
    // Adds two length-m vectors over Rq=Zq[X]/(X^N+1), where the second vector
    // starts with m-num_messages 0s followed by num_messages arbitrary polynomials
    // the second vector is only specified via its last num_messages entries.
    // Representatives in [0,q-1] = Lattice Field
    // qbits = ceil(log2(q))
    // NOTE: This is written under the assumption that the input polynomials are in Zq[X], i.e., the coefficients are in [0,q-1]

    input signal in1[m][N];
    input signal in2[num_messages][N];
    output signal out[m][N];
    var n=m-num_messages;
    component addPolysModQ[num_messages];

    for (var i=0; i<n;i++){
        for (var s=0; s<N; s++){
            out[i][s] <== in1[i][s];
        }
    }
    for (var i=n; i<m; i++){
        addPolysModQ[n-i] = addDegreeNPolynomialsModQ(N,q);
        addPolysModQ[n-i].P1 <== in1[i];
        addPolysModQ[n-i].P2 <== in2[n-i];
        for (var s=0; s<N; s++){
            out[i][s] <== addPolysModQ[n-i].result[s];
        }
    }

}

template computeInfinityNormInteger(N){
    // Computes infty Norm of a length N vector/polynomial in Z
    input signal polynomial[N];
    output signal result;

    signal max <== 0;
    for (var i=0; i<N; i++){
        if (polynomial[i] > max){
            max <== polynomial[i];
        }
        if (-polynomial[i] > max){
            max <== -polynomial[i];
        }
    }
    result <== max;
}

template assertInfinityNormModQOne(N,q){
    // Asserts that the infty Norm of a length N vector/polynomial over Zq is 1
    // NOTE: Only works for coefficients in [0,q-1]
    input signal polynomial[N];
    signal aux1[N];
    signal aux2[N];

    for (var i=0; i<N; i++){
        aux1[i]<--polynomial[i]*(polynomial[i]-1); // 0 or 1
        aux2[i]<--aux1[i]*(polynomial[i]+1-q); // or -1 mod q
        aux2[i]===0;
    }
}

template assertProductOfPublicPolynMatrixWithSecretPolyVector(matrix,N,m,k){
    // Multiplies a public mxk Matrix over Rq with a vector in Rq^k
    // Here, Rq=Zq[X]/(X^N+1), Assumption: SNARK field = Lattice field
    input signal vector[k][N];
    input signal quotientvector[m][N]; //should be computed then constrained
    input signal result[m][N];
    // input signal matrix[m][k][N]; //this should be a constant
    signal claimed[m][2*N-1];
    signal prodvector[m][2*N-1];
    signal aux[m][k][N][N];
    // var acc[m][2*N-1];
    // var matrix[m][k][N];
    // var quotientTimesModulus[m][2*N-1];
    // var paddedResult[m][2*N-1];

    component addDegree2N[m];


    for (var j=0; j<m; j++){ //j-th vector entry
        var acc[2*N-1];
        for (var s=0; s<2*N-1; s++){
        acc[s]=0; //instantiate as zero Polynomial
        }
        for (var i=0; i<k; i++){ //i-th summand
            for (var s=0; s<N; s++){ //(s+t)-th coefficient
                for (var t=0; t<N; t++){
                    aux[j][i][s][t] <== matrix[j][i][s]*vector[i][t];
                    acc[s+t]+=aux[j][i][s][t]; //No reduction mod X^N+1 yet
                }
            }
        }
        for (var s=0; s<2*N-1;s++){
            prodvector[j][s] <== acc[s];
        }
    }

    for (var j=0; j<m; j++){
        addDegree2N[j]=addDegreeNPolynomials(2*N-1);
        for (var s=0; s<N; s++){
            addDegree2N[j].P1[s] <== quotientvector[j][s];
            addDegree2N[j].P2[s] <== result[j][s];
        }
        for (var s=N; s<2*N-1;s++){
            addDegree2N[j].P1[s] <== quotientvector[j][s-N];
            addDegree2N[j].P2[s] <== 0;
        }
        for (var s=0; s<2*N-1; s++){
            claimed[j][s] <-- addDegree2N[j].result[s];
            claimed[j][s] === prodvector[j][s];
        }
    }
}

template computeProductOfPublicPolynMatrixWithSecretPolyVector(matrix,N,m,k,q){
    // Multiplies a public mxk Matrix over R with a vector in R^k
    // Here, R=Fp[X]/(X^N+1), where Fp is the SNARK field
    // The computation respects modulo q overlap if all entries are in [0,q-1]
    // That is, taking the result modulo q will yield the correct value (but the result won't be in [0,q-1] before doing so)

    input signal vector[k][N];
    output signal result[m][N];
    signal prodvector[m][2*N];
    signal aux[m][k][N][N];

    component addDegree2N[m];

    for (var j=0; j<m; j++){ //j-th vector entry
        var acc[2*N];
        for (var s=0; s<2*N; s++){
        acc[s]=0; //instantiate as zero Polynomial
        }
        for (var i=0; i<k; i++){ //i-th summand
            for (var s=0; s<N; s++){ //(s+t)-th coefficient
                for (var t=0; t<N; t++){
                    aux[j][i][s][t] <== matrix[j][i][s]*vector[i][t];
                    acc[s+t]+=aux[j][i][s][t]; //No reduction mod X^N+1 yet
                }
            }
        }
        for (var s=0; s<2*N;s++){
            prodvector[j][s] <== acc[s];
        }
    }

    // entries of prodvector are bounded by k*N²*q², hence, substraction is realized securely

    for (var j=0;j<m;j++){
        for (var s=0; s<N; s++){
            result[j][s] <== prodvector[j][s] + k*N**2*q**2 - prodvector[j][N+s];
        }
    }
}