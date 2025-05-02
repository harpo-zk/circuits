pragma circom 2.1.6;

include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/escalarmulany.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/babyjub.circom";

template PrivateDataVerifier(publicKeys) {
    signal input publicKey[publicKeys][2];
    signal input nonce[publicKeys];
    signal input data;
    signal input cipher[publicKeys];

    component encryptedData[publicKeys];
    for(var i = 0; i < publicKeys; i++) {
        encryptedData[i] = EncryptData();
        encryptedData[i].publicKey <== publicKey[i];
        encryptedData[i].msg <== data;
        encryptedData[i].nonce <== nonce[i];

        encryptedData[i].cipher === cipher[i];
    }
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

component main { public [ cipher ] } = PrivateDataVerifier(2);
