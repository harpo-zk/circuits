pragma circom 2.2.0;

include "../../../node_modules/circomlib/circuits/comparators.circom";

template PositiveValuesIsolated(nValues){
    signal input values[nValues]; 
    component pos[nValues];

    for( var i=0; i < nValues; i++){
        pos[i] = GreaterThan(64);
        pos[i].in[0] <== values[i];
        pos[i].in[1] <== 0;
        pos[i].out === 1;
    }
}

component main = PositiveValuesIsolated(3);