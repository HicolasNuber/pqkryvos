pragma circom 2.2.2;

include "polynomials.circom";

function multiplyPolynomialsModPhi(aux,comkey,r,N,s){
    for (var t = 0; t < N; t++) {
                if (s - t >= 0) {
                    aux += comkey[t] * r[s - t];
                }
                if (729 + s - t < 486) {
                    aux += comkey[t] * r[729 + s - t];
                }
                if (486 + (s % 243) - t < 486) {
                    aux -= comkey[t] * r[486 + (s % 243) - t];
                }
            }
    return aux;
}



function commitPolynomialsModPhi(aux, comkey,r,x,N,n,k){
    for (var s = 0; s < N; s++) {
        for (var i = 0; i < n + 1; i++) {

            if (i != n) {
                aux[i][s] = r[k - n + i][s];
            } else {
                aux[i][s] = r[k - n - 1][s];
            }

            for (var j = 0; j < k - n; j++) {

                if ((i != n) || (j != k - n - 1)) {
		        aux[i][s] += multiplyPolynomialsModPhi(aux[i][s],comkey[i][j],r[j],N,s);
            }
}

            if (i == n) {
                aux[i][s] += x[s];
            }
        }
    }
    return aux;
}

