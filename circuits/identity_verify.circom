pragma circom 2.2.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/babyjub.circom";

template IdentityVerify(){
    signal input privateKey;    
    signal input nonce;
    
    signal output commitment;    

    component pubFromPriv = BabyPbk(); 
    pubFromPriv.in <== privateKey; 

    commitment <== Poseidon(3)([
        pubFromPriv.Ax,pubFromPriv.Ay,nonce             
    ]); 
}

component main = IdentityVerify();