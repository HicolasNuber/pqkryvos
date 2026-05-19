pragma circom 2.2.2;

include "../../../../src/crypto/commitment.circom";

template testMain(){
    var N=486;
    var n=6;
    var k=13;
    var comkey[n+1][k][N];

    for (var i=0; i<n+1; i++) {
        for (var j=0; j<k; j++) {
            for (var s=0; s<N; s++) {
                comkey[i][j][s]=2; // default placeholder
            }
        }
    }
    signal input message[N];
    signal input randomness[k][N];
    signal output commitment[n+1][N];

    component test = commitSnarkField(comkey,N,n,k);
    test.x <== message;
    test.r <== randomness;
    commitment <== test.commitment;
}

component main = testMain();
