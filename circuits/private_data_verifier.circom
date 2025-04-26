pragma circom 2.1.6;

include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/escalarmulany.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/babyjub.circom";

template PrivateDataVerifier() {
    signal input publicKey[2][2];
    signal input nonce[2];
    signal input data;
    signal input cipher[2];

    component encryptedDataOne = EncryptData();
    encryptedDataOne.publicKey <== publicKey[0];
    encryptedDataOne.msg <== data;
    encryptedDataOne.nonce <== nonce[0];

    component encryptedDataTwo = EncryptData();
    encryptedDataTwo.publicKey <== publicKey[1];
    encryptedDataTwo.msg <== data;
    encryptedDataTwo.nonce <== nonce[1];

    encryptedDataOne.cipher === cipher[0];
    encryptedDataTwo.cipher === cipher[1];
}

template EncryptData() {
    signal input publicKey[2];
    signal input msg;
    signal input nonce;
    signal output cipher;

    component nonceBits = Num2Bits(253);
    nonceBits.in <== nonce;

    component sharedPoint = EscalarMulAny(253);
    sharedPoint.p[0] <== publicKey[0];
    sharedPoint.p[1] <== publicKey[1];

    for (var j = 0; j < 253; j++) {
        sharedPoint.e[j] <== nonceBits.out[j];
    }

    signal sharedKey <== Poseidon(1)([sharedPoint.out[0]]);
    cipher <== msg + sharedKey;
} 

component main { public [ cipher ] } = PrivateDataVerifier();
