pragma circom 2.2.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

/*
 * token_settlement_verify — settlement confidencial de uma transferencia de
 * token: prova que "token T, valor A, do endereco S para o endereco R, sob a
 * referencia de liquidacao settlementRef" corresponde ao commitment publico,
 * sem revelar nenhum desses campos.
 *
 * Privados : tokenId, amount, sender, receiver, salt, settlementRef
 * Publicos : commitment, settlementRefHash
 */
template TokenSettlementVerify() {
    signal input tokenId;        // identificador do token/ativo (ex.: uint160 do endereco ERC-20, como field element)
    signal input amount;         // quantidade transferida
    signal input sender;         // endereco de origem, como field element
    signal input receiver;       // endereco de destino, como field element
    signal input salt;           // blinding
    signal input settlementRef;  // referencia da liquidacao no rail de token (ex.: id de uma ordem/trade)

    signal input commitment;         // Poseidon(tokenId, amount, sender, receiver, salt)
    signal input settlementRefHash;  // Poseidon(settlementRef); usado on-chain para anti-replay

    component hCommit = Poseidon(5);
    hCommit.inputs[0] <== tokenId;
    hCommit.inputs[1] <== amount;
    hCommit.inputs[2] <== sender;
    hCommit.inputs[3] <== receiver;
    hCommit.inputs[4] <== salt;
    commitment === hCommit.out;

    component hRef = Poseidon(1);
    hRef.inputs[0] <== settlementRef;
    settlementRefHash === hRef.out;
}

component main {public [commitment, settlementRefHash]} = TokenSettlementVerify();
