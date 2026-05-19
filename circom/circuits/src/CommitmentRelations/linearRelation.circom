pragma circom 2.2.2;

include "../utilities/mult486.circom";

template linearRelation(a,b,comkey,N,n,k){
    signal input x[N];
    signal input y[N];

/* Setting the lineare relation for all polynomial coefficients */ 

    var lincom[N];

    for (var s=0; s<N; s++){
	lincom[s] = 0;
        lincom[s] = multiplyPolynomialsModPhi(lincom[s],a,x,N,s);
        lincom[s] = multiplyPolynomialsModPhi(lincom[s],b,y,N,s);
        0 === lincom[s];
    }
}
