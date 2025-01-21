pragma circom 2.2.0;

include "../node_modules/circomlib/circuits/smt/smtverifier.circom";

template CalculateMerkleRoot(nIn){

    signal input commitments[nIn]; 
    signal input siblingsArray[nIn][16];
    signal input merkleRoot; 

    component smtVerifier[nIn];

    for(var i=0; i<nIn; i++){
        smtVerifier[i] = SMTVerifier(16);// 16 é a profundidade da arvore
        smtVerifier[i].enabled <== 1;
        smtVerifier[i].root <== merkleRoot;
        for (var j = 0; j < 16; j++) {
            smtVerifier[i].siblings[j] <== siblingsArray[i][j];
        }
        smtVerifier[i].key <== commitments[i];
        smtVerifier[i].value <== commitments[i];
        // 0 -> verifica inclusao
        smtVerifier[i].fnc <== 0;        
        // usados para verificar exclusao
        smtVerifier[i].oldKey <== 0;        
        smtVerifier[i].oldValue <== 0;
        smtVerifier[i].isOld0 <== 0;
    }
    
}