pragma circom 2.2.2;

include "polynomials.circom";

template multiplyPolynomialsModPhi(N){
    // Multiply two polynomials in Fp[X]/(Phi(X)), where Fp is the SNARK field
    // var N=486; // N will be fixed, but for testing purposes we vary
    input signal P1[N];
    input signal P2[N];
    output signal result[N];

    // First compute the coefficients in Fp[X]

    var l=2*N;
    signal product[l];
    signal t1s[N][N];

    var acc[l];
    for (var i=0; i<l; i++){
            acc[i]=0;
    }

    for (var i=0; i<N; i++){
        for (var j=0; j<N; j++){
            t1s[i][j] <== P1[i]*P2[j];
            acc[i+j] += t1s[i][j];
        }
    }

    product <== acc;

    // Now compute result modulo Phi(X)

    //Real Computation:
    for (var k=0; k<N; k++){
        if(k<243){
            result[k] <== product[k]-product[486+k]+product[729+k];
        }
        else {
            result[k] <== product[k]-product[243+k];
        }
    }
}

template multiplyPublicPolynomialMatrixWithPolynomialVectorModPhi(matrix,N,m,k){
    // Multiplies a public mxk Matrix over Rq with a vector in Rq^k
    // Here, Rq=Zq[X]/(Phi(X)), Assumption: SNARK field = Lattice field
    // var N=486; // N will always be 486, but for test purposes we make it smaller
    input signal vector[k][N];
    output signal result[m][N];
    // signal acc[m][k][N];
    component polymult[m][k];

    for (var i=0; i<m; i++){
        var acc[N];
        
        for (var s=0; s<N; s++){
                acc[s]=0;
            }

        for (var j=0; j<k; j++){
            polymult[i][j]=multiplyPolynomialsModPhi(N);
            polymult[i][j].P1 <== matrix[i][j];
            polymult[i][j].P2 <== vector[j];
        }
        for (var j=0; j<k; j++){
            for (var s=0; s<N; s++){
                acc[s]+=polymult[i][j].result[s];
            }
        }
        result[i] <== acc;
    }
}
