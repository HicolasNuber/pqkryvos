pragma circom 2.2.2;

include "../utilities/polynomials.circom";
include "../utilities/mult486.circom";


template commit(comkey, N, n, k, q) {

    // Inputs
    signal input x[N];
    signal input r[k][N];

    // Outputs
    signal output commitment[n+1][N];

    // --- Input-Checks ---

    component checkQMessage = assertPolynomialEntriesModQ(N, q);
    checkQMessage.P <== x;

    component checkQRandomness[k];
    for (var i = 0; i < k; i++) {
        checkQRandomness[i] = assertPolynomialEntriesModQ(N, q);
        checkQRandomness[i].P <== r[i];
    }

    component checkSbeta[k];
    for (var i = 0; i < k; i++) {
        checkSbeta[i] = assertInfinityNormModQOne(N, q);
        checkSbeta[i].polynomial <== r[i];
    }

    // --- Matrix-Vector Product Ar + x (before mod q) ---

    var aux[n+1][N];

    for (var s = 0; s < N; s++) {
        for (var i = 0; i < n + 1; i++) {

            if (i != n) {
                aux[i][s] = r[k - n + i][s]; // id_{ij} r_{j+k-n}
            } else {
                aux[n][s] = r[k - n - 1][s]; // 1 in last row of A at position k-n-1
            }

            for (var j = 0; j < k - n; j++) {

                // exclude position (n, k-n-1) — already set above
                if ((i != n) || (j != k - n - 1)) {

                    for (var t = 0; t < N; t++) {

                        if (s - t >= 0) {
                            aux[i][s] += comkey[i][j][t] * r[j][s - t];
                        }

                        if (256 + s - t < 256) {
                            aux[i][s] += (q**2)-comkey[i][j][t] * r[j][256 + s - t];
                        }
                    }
                }
            }

            if (i == n) {
                aux[i][s] += x[s]; // add x to last row
            }
        }
    }

    // --- Mod-q reduction of all (n+1) components ---

    var BOUND = 2*k*N*(q**2) + 2*q;

    component polyModQ[n + 1];
    for (var i = 0; i < n + 1; i++) {
        polyModQ[i] = degreeNPolynomialModuloQ(N, q, BOUND);
        polyModQ[i].P <== aux[i];
        commitment[i] <== polyModQ[i].result;
    }
}

template commitSnarkField(comkey, N, n, k) {

    // Inputs
    signal input x[N];
    signal input r[k][N];

    // Outputs
    signal output commitment[n+1][N];

    // --- Norm-Checks ---

    signal norm[k][N];
    for (var i = 0; i < k; i++) {
        for (var s = 0; s < N; s++) {
            norm[i][s] <== r[i][s] * r[i][s] - 1;
            0 === norm[i][s] * r[i][s];
        }
    }

    // --- Matrix-Vector Product Ar + x ---

    for (var s = 0; s < N; s++) {
        for (var i = 0; i < n + 1; i++) {
            var aux;
            if (i != n) {
                aux = r[k - n + i][s];
            } else {
                aux = r[k - n - 1][s];
            }
            for (var j = 0; j < k - n; j++) {
                if ((i != n) || (j != k - n - 1)) {
		            aux += multiplyPolynomialsModPhi(aux,comkey[i][j],r[j],N,s);
                }
            }

            if (i == n) {
                aux += x[s];
            }

            commitment[i][s] <== aux;
        }
    }
}

template commitSnarkFieldArray(comkey, N, n, k) {

    // Inputs
    signal input x[N];
    signal input r[k][N];

    // Outputs
    signal output commitment[n+1][N];

    // --- Norm-Checks ---

    signal norm[k][N];
    for (var i = 0; i < k; i++) {
        for (var s = 0; s < N; s++) {
            norm[i][s] <== r[i][s] * r[i][s] - 1;
            0 === norm[i][s] * r[i][s];
        }
    }

    // --- Matrix-Vector Product Ar + x ---

    var aux[n+1][N];
    aux = commitPolynomialsModPhi(aux, comkey,r,x,N,n,k);
    commitment<== aux;
}

