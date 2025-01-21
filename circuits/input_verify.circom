pragma circom 2.2.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/babyjub.circom";
include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/escalarmulany.circom";

template InputVerify(){
    signal input privateKey;    
    signal input message[15];

    signal output nullifier;
    signal output commitment;    

    signal secret[15];   

    component encMessage = EncryptMessage();
    encMessage.privateKey <== privateKey;    
    encMessage.msg <== message;
        
    secret <== encMessage.cipherMsg;   

    var chunk1 = Poseidon(5)([
        secret[0],
        secret[1],
        secret[2],
        secret[3],
        secret[4]
    ]);

    var chunk2 = Poseidon(5)([
        secret[5],
        secret[6],
        secret[7],
        secret[8],
        secret[9]
    ]);
    
    var chunk3 = Poseidon(5)([
        secret[10],
        secret[11],
        secret[12],
        secret[13],
        secret[14]
    ]);

    commitment <== Poseidon(3)([
        chunk1,chunk2,chunk3             
    ]); 

    nullifier <== Poseidon(2)([commitment,privateKey]);
}

template EncryptMessage() {
    signal input privateKey;    
    signal input msg[15];                     
    signal output cipherMsg[15];    

    component c1verify = BabyPbk(); 
    c1verify.in <== msg[2];    

    component pubFromPriv = BabyPbk(); 
    pubFromPriv.in <== privateKey;  
    
    component mulFix2 = EscalarMulAny(253);
    mulFix2.p[0] <== pubFromPriv.Ax;
    mulFix2.p[1] <== pubFromPriv.Ay;    

    component privBits2 = Num2Bits(253);
    privBits2.in <== msg[2]; 

    for (var j = 0; j < 253; j++) {
        mulFix2.e[j] <== privBits2.out[j];
    }

    signal sharedKey;
    signal sharedPointX;

    sharedPointX <== mulFix2.out[0];
    _ <== mulFix2.out[1];
    
    sharedKey <== Poseidon(1)([sharedPointX]); 

    cipherMsg[0] <== c1verify.Ax;
    cipherMsg[1] <== c1verify.Ay;
    cipherMsg[2] <== msg[2] + sharedKey;
    cipherMsg[3] <== msg[3] + msg[2] + sharedKey;  
    cipherMsg[4] <== msg[4] + msg[2] + sharedKey;  
    cipherMsg[5] <== msg[5] + msg[2] + sharedKey;  
    cipherMsg[6] <== msg[6] + msg[2] + sharedKey;  
    cipherMsg[7] <== msg[7] + msg[2] + sharedKey;  
    cipherMsg[8] <== msg[8] + msg[2] + sharedKey;  
    cipherMsg[9] <== msg[9] + msg[2] + sharedKey;
    cipherMsg[10] <== msg[10] + msg[2] + sharedKey;  
    cipherMsg[11] <== msg[11] + msg[2] + sharedKey;  
    cipherMsg[12] <== msg[12] + msg[2] + sharedKey;  
    cipherMsg[13] <== msg[13] + msg[2] + sharedKey;  
    cipherMsg[14] <== msg[14] + msg[2] + sharedKey;     
}