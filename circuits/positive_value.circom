pragma circom 2.2.0;

include "../node_modules/circomlib/circuits/comparators.circom";

// recebe os amounts de saida e verifica se são positivos maiores q zero, 
// não precisa validar entrada, uma vez q entradas são saídas que foram validadas.

template PositiveValues(nValues){

    signal input values[nValues]; 

    component pos[nValues];

    for( var i=0; i < nValues; i++){
        pos[i] = GreaterThan(64);// 64 is the number of bits the input  have.
        pos[i].in[0] <== values[i];
        pos[i].in[1] <== 0;
        pos[i].out === 1;
    }
    
}