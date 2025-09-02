pragma circom 2.2.0;

include "../../../node_modules/circomlib/circuits/comparators.circom";

template PositiveValuesTest(nValues){
    signal input values[nValues]; 
    component pos[nValues];

    for( var i=0; i < nValues; i++){
        pos[i] = GreaterThan(64);
        pos[i].in[0] <== values[i];
        pos[i].in[1] <== 0;
        pos[i].out === 1;
    }
}

template InOutZeroSumIsolated(nIn, nOut){
    signal input inValues[nIn]; 
    signal input outValues[nOut]; 

    var accIn = 0;
    var accOut = 0;

    component positiveValuesGreaterThanZero = PositiveValuesTest(nOut);
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

component main = InOutZeroSumIsolated(2, 2);