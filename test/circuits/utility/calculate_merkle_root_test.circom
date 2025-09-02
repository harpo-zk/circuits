pragma circom 2.2.0;

include "../../../node_modules/circomlib/circuits/poseidon.circom";

template CalculateMerkleRoot(levels) {
    signal input leaf;
    signal input siblings[levels];
    signal input indices[levels];
    signal output root;
    
    component hashers[levels];
    signal hashes[levels + 1];
    hashes[0] <== leaf;
    
    for (var i = 0; i < levels; i++) {
        hashers[i] = Poseidon(2);
        hashers[i].inputs[0] <== hashes[i];
        hashers[i].inputs[1] <== siblings[i];
        hashes[i + 1] <== hashers[i].out;
    }
    
    root <== hashes[levels];
}

component main = CalculateMerkleRoot(2);