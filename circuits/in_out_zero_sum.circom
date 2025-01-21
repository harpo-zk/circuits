pragma circom 2.2.0;

include "../node_modules/circomlib/circuits/comparators.circom";
include "positive_value.circom";
// verifica se a soma das entradas é igual a soma das saidas

template InOutZeroSum(nIn, nOut){

    signal input inValues[nIn]; 
    signal input outValues[nOut]; 

    var accIn = 0;
    var accOut = 0;

    component positiveValuesGreaterThanZero = PositiveValues(nOut);
    positiveValuesGreaterThanZero.values <== outValues;

    for(var i=0; i<nIn; i++){
        accIn = accIn + inValues[i];
    }

    for(var j=0; j<nOut; j++){
        accOut = accOut + outValues[j];
    }    

    component isEqual = IsEqual();
    isEqual.in[0] <== accIn;
    isEqual.in[1] <== accOut;
    isEqual.out === 1;
    
}