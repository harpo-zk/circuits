pragma circom 2.2.0;

include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/escalarmulany.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/babyjub.circom";

template AuditSecretVerify(nIn, nOut){

    signal input nonce;
    signal input privKeyInput;
    signal input destinyPubKey[2];  
    signal input tokenType;
    signal input amountsIn[nIn]; 
    signal input amountsOut[nOut];
    signal input pubKeyAuthority[2];

    signal output auditSecret[8 + nIn + nOut]; 

    signal originPubKey[2]; 

    component c1verify = BabyPbk(); 
    c1verify.in <== nonce;  

    component pubFromPriv = BabyPbk(); 
    pubFromPriv.in <== privKeyInput;  

    originPubKey[0] <== pubFromPriv.Ax;
    originPubKey[1] <== pubFromPriv.Ay;   
    
    component mulFix2 = EscalarMulAny(253);
    mulFix2.p[0] <== pubKeyAuthority[0];
    mulFix2.p[1] <== pubKeyAuthority[1];    

    component privBits2 = Num2Bits(253);
    privBits2.in <== nonce; 

    for (var j = 0; j < 253; j++) {
        mulFix2.e[j] <== privBits2.out[j];
    }

    signal sharedKey;
    signal sharedPointX;

    sharedPointX <== mulFix2.out[0];
    _ <== mulFix2.out[1];
    
    sharedKey <== Poseidon(1)([sharedPointX]); 
       
    auditSecret[0] <== c1verify.Ax;
    auditSecret[1] <== c1verify.Ay;
    auditSecret[2] <== nonce + sharedKey;
    auditSecret[3] <== tokenType +  auditSecret[2];   
    auditSecret[4] <== originPubKey[0] +  nonce;
    auditSecret[5] <== originPubKey[1] +  nonce;  

    auditSecret[6] <== destinyPubKey[0] +  nonce;  
    auditSecret[7] <== destinyPubKey[1] +  nonce;

    for(var m=1; m<nIn+1; m++){
        auditSecret[7+m] <== amountsIn[m-1] +  auditSecret[2];
    }

    for(var n=1; n<nOut+1; n++){
        auditSecret[7+nIn+n] <== amountsOut[n-1] +  auditSecret[2];
    }
    
}