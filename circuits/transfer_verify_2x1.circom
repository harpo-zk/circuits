pragma circom 2.2.0;

include "input_verify.circom";
include "in_out_zero_sum.circom";
include "output_verify.circom";
include "audit_secret_verify.circom";
include "calculate_merkle_root.circom";

template TransferVerify(nInputs, nOuts){
    signal input msgInputs[nInputs][15];
    signal input privKeyInput;
    signal input tokenOutputs[nOuts][15];
    signal input pubKeyOutputs[nOuts][2];
    signal input siblingsArray[nInputs][16];
    signal input merkleRoot;
    signal input pubKeyAuthority[2];

    signal output nullifierInputs[nInputs];   
    signal output commitmentOutputs[nOuts];
    signal output auditSecret[8 + nInputs + nOuts];

    signal commitmentInputs[nInputs];    
    
    component inputVerify[nInputs];
    component outputVerify[nOuts];

    var inAmounts[nInputs];
    var outAmounts[nOuts];

    for (var j=0; j<nInputs; j++) {
        inputVerify[j] = InputVerify();
        inputVerify[j].privateKey <== privKeyInput;
        inputVerify[j].message <== msgInputs[j];

        inAmounts[j] = msgInputs[j][6];
        
        nullifierInputs[j] <== inputVerify[j].nullifier;
        commitmentInputs[j] <== inputVerify[j].commitment; 
               
    }
    component calculateMerkleRoot = CalculateMerkleRoot(nInputs);

    calculateMerkleRoot.commitments <== commitmentInputs;
    calculateMerkleRoot.siblingsArray <== siblingsArray;
    calculateMerkleRoot.merkleRoot <==  merkleRoot;
    
    for (var k=0; k<nOuts; k++) {
        outputVerify[k] = OutputVerify();
        outputVerify[k].publicKey <== pubKeyOutputs[k];
        outputVerify[k].message <== tokenOutputs[k];
        
        outAmounts[k] = tokenOutputs[k][6];
        
        commitmentOutputs[k] <== outputVerify[k].commitment;        
    }

    component verifyAuditSecret = AuditSecretVerify(nInputs,nOuts);
             
    verifyAuditSecret.nonce <== msgInputs[0][2];
    verifyAuditSecret.privKeyInput <== privKeyInput;
    verifyAuditSecret.destinyPubKey <== pubKeyOutputs[0];
    verifyAuditSecret.tokenType <== msgInputs[0][5];
    verifyAuditSecret.amountsIn <== inAmounts;
    verifyAuditSecret.amountsOut <== outAmounts;
    verifyAuditSecret.pubKeyAuthority <== pubKeyAuthority;

    auditSecret <== verifyAuditSecret.auditSecret;

    component verifyMassConservation = InOutZeroSum(nInputs, nOuts);
    verifyMassConservation.inValues <== inAmounts;
    verifyMassConservation.outValues <== outAmounts;
    
}

component main = TransferVerify(2,1);