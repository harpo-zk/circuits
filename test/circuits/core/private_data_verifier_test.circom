pragma circom 2.2.0;

include "../../../node_modules/circomlib/circuits/poseidon.circom";
include "../../../node_modules/circomlib/circuits/babyjub.circom";
include "../../../node_modules/circomlib/circuits/bitify.circom";
include "../../../node_modules/circomlib/circuits/escalarmulany.circom";

template PrivateDataVerify() {
    signal input publicKey[2][2];
    signal input nonce[2];
    signal input message[15];
    signal input randomness[15];
    
    signal output cipher[2][15];
    signal output commitment;
    
    component poseidon = Poseidon(2);
    poseidon.inputs[0] <== message[0];
    poseidon.inputs[1] <== randomness[0];
    commitment <== poseidon.out;
    
    for (var i = 0; i < 15; i++) {
        cipher[0][i] <== message[i];
        cipher[1][i] <== randomness[i];
    }
}

component main = PrivateDataVerify();