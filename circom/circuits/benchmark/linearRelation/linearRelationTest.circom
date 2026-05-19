pragma circom 2.2.2;

include "../../src/CommitmentRelations/linearRelation.circom";
include "../../src/crypto/commitment.circom";


template testMain(){

    var N=486;
    var n=1;
    var k=3;
    var comkey[n+1][k][N];
    var a[N];
    var b[N];

    signal input x1[N];
    signal input x2[N];
    signal input randomness1[k][N];
    signal input randomness2[k][N];
    signal output commit1[n+1][N];
    signal output commit2[n+1][N];

    for (var i=0; i<n+1; i++) {
        for (var j=0; j<k; j++) {
            for (var s=0; s<N; s++) {
                comkey[i][j][s]=2; // default placeholder
            }
        }
    }

    for (var s=0; s<N; s++) {
                a[s]=2; // default placeholder
            }

    for (var s=0; s<N; s++) {
                b[s]=2; // default placeholder
            }

/**
 * Computes two commitments to values x_1,x_2 in a public linear relation ax_2+bx_2=0 for fixed polynomials a,b assuming SNARK field == Lattice Field.
 *
 *
 *   Commitment parameters:
 *   - N: degree of the cyclotomic polynomial.
 *   - n: commitment dimension - 1 (del Pino d)
 *   - k: randomness dimension (del Pino 2d+1)
 *   - comkey[n+1][k][N]: (n+1)xk matrix of degree-N-polynomials in Zq[X]
 */

    component test1 = commitSnarkField(comkey,N,n,k);
    test1.x <== x1;
    test1.r <== randomness1;
    commit1 <== test1.commitment;
    component test2 = commitSnarkField(comkey,N,n,k);
    test2.x <== x2;
    test2.r <== randomness2;
    commit2 <== test2.commitment;

/*
 *   Linear Relation parameters:
 *   - a,b: degree-N-polynomials in Zq[X]
 */

    component test3 = linearRelation(a,b,comkey,N,n,k);
    test3.x <== x1;
    test3.y <== x2;
}

component main = testMain();
