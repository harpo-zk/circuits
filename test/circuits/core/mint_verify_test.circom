pragma circom 2.2.0;

include "../../../node_modules/circomlib/circuits/poseidon.circom";
include "../../../node_modules/circomlib/circuits/comparators.circom";

template PositiveValue() {
    signal input value;
    signal output out;
    component gt = GreaterThan(64);
    gt.in[0] <== value;
    gt.in[1] <== 0;
    out <== gt.out;
}

template MintVerify() {
    signal input amountR;
    signal output commitment;
    signal output nullifier;
    
    component poseidon = Poseidon(2);
    poseidon.inputs[0] <== amountR;
    poseidon.inputs[1] <== 1;
    commitment <== poseidon.out;
    nullifier <== poseidon.out;
    
    component positiveValue = PositiveValue();
    positiveValue.value <== amountR;
    positiveValue.out === 1;
}

component main = MintVerify();