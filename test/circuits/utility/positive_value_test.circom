pragma circom 2.2.0;

include "../../../node_modules/circomlib/circuits/comparators.circom";

template PositiveValues(n) {
    signal input values[n];
    signal output out;
    
    component gt[n];
    signal products[n + 1];
    products[0] <== 1;
    
    for (var i = 0; i < n; i++) {
        gt[i] = GreaterThan(64);
        gt[i].in[0] <== values[i];
        gt[i].in[1] <== 0;
        products[i + 1] <== products[i] * gt[i].out;
    }
    
    out <== products[n];
}

component main = PositiveValues(3);