pragma circom 2.2.0;

include "output_verify.circom";
include "../node_modules/circomlib/circuits/comparators.circom";
include "positive_value.circom";

template MintPropertyTokenVerify(){     
    signal input tokenOutput[15];
    signal input privKeyAuthority;  
    
    signal output commitmentOutput;
    signal output amount;
    signal output pubKeyJubX;
    signal output pubKeyJubY;  
    signal output numMatriculaOutput;
   
    signal publicKeyAuthority[2];          
        
    component outputVerify = OutputVerify();  

    component pubFromPriv = BabyPbk(); 
    pubFromPriv.in <== privKeyAuthority;    

    publicKeyAuthority[0] <== pubFromPriv.Ax;
    publicKeyAuthority[1] <== pubFromPriv.Ay;
    
    outputVerify.publicKey <== publicKeyAuthority;
    outputVerify.message <== tokenOutput;
    commitmentOutput <== outputVerify.commitment;
    
    amount <== tokenOutput[6];
    pubKeyJubX <== tokenOutput[3];
    pubKeyJubY <== tokenOutput[4];
    numMatriculaOutput <== tokenOutput[7];

    amount === 1;
    pubKeyJubX === tokenOutput[3];
    pubKeyJubY === tokenOutput[4];
        
}

component main = MintPropertyTokenVerify();