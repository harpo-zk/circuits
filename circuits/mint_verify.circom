pragma circom 2.2.0;

include "output_verify.circom";
include "../node_modules/circomlib/circuits/comparators.circom";
include "positive_value.circom";

template MintVerify(){     
    signal input tokenOutput[15];
    signal input pubKeyOutput[2];   
    
    signal output commitmentOutput;
    signal output amount;
    signal output pubKeyJubX;
    signal output pubKeyJubY;  

    signal amountR[1];            
        
    component outputVerify = OutputVerify();    
    
    outputVerify.publicKey <== pubKeyOutput;
    outputVerify.message <== tokenOutput;
    commitmentOutput <== outputVerify.commitment;
    
    pubKeyJubX <== pubKeyOutput[0];
    pubKeyJubY <== pubKeyOutput[1];
    amount <== tokenOutput[6];
    amountR[0] <== tokenOutput[6];
      
    component positiveValuesGreaterThanZero = PositiveValues(1);
    positiveValuesGreaterThanZero.values <== amountR; 
    
}

component main = MintVerify();