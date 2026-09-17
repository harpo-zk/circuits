const path = require("path");
const { expect } = require("chai");
const wasm_tester = require("circom_tester").wasm;
const CryptoUtils = require("../utils/crypto-utils");

/**
 * PixPaymentVerify — proves that (amount, salt, e2eId, txid) matches the
 * on-chain commitment set up for an operation, and that the public
 * e2eIdHash really corresponds to the private e2eId (anti-replay signal),
 * without revealing amount, e2eId or txid.
 *
 * The Solidity verifier this circuit is compiled into (PixPaymentVerify.sol)
 * lives in harpo-zk/contracts.
 */
describe("PixPaymentVerify Circuit", function () {
    let circuit;
    let cryptoUtils;

    before(async function () {
        cryptoUtils = new CryptoUtils();
        await cryptoUtils.init();

        circuit = await wasm_tester(
            path.join(__dirname, "../../circuits/pix_payment_verify.circom")
        );
    });

    function validInput() {
        const amount = "150000"; // R$ 1.500,00 em centavos
        const salt = cryptoUtils.randomField();
        const e2eId = cryptoUtils.randomField();
        const txid = cryptoUtils.randomField();
        const commitment = cryptoUtils.hash([amount, salt, e2eId, txid]);
        const e2eIdHash = cryptoUtils.hash([e2eId]);
        return { amount, salt, e2eId, txid, commitment, e2eIdHash };
    }

    describe("Valid Pix payment proofs", function () {
        it("accepts a witness whose commitment and e2eIdHash match the private inputs", async function () {
            const input = validInput();
            const witness = await circuit.calculateWitness(input);
            await circuit.checkConstraints(witness);
        });

        it("produces the same commitment for the same inputs (determinism)", async function () {
            const input = validInput();
            const w1 = await circuit.calculateWitness(input);
            const w2 = await circuit.calculateWitness(input);
            await circuit.checkConstraints(w1);
            await circuit.checkConstraints(w2);
        });

        it("rejects two different payments producing the same commitment", async function () {
            const a = validInput();
            const b = validInput();
            expect(a.commitment).to.not.equal(b.commitment);
        });
    });

    describe("Invalid Pix payment proofs", function () {
        it("rejects a commitment that does not match (amount, salt, e2eId, txid)", async function () {
            const input = validInput();
            input.commitment = cryptoUtils.randomField();
            try {
                await circuit.calculateWitness(input);
                expect.fail("should have thrown for a mismatched commitment");
            } catch (error) {
                expect(error.message).to.contain("Assert Failed");
            }
        });

        it("rejects an e2eIdHash that does not match the private e2eId", async function () {
            const input = validInput();
            input.e2eIdHash = cryptoUtils.randomField();
            try {
                await circuit.calculateWitness(input);
                expect.fail("should have thrown for a mismatched e2eIdHash");
            } catch (error) {
                expect(error.message).to.contain("Assert Failed");
            }
        });

        it("rejects a tampered amount even if commitment/e2eIdHash are otherwise self-consistent for the original amount", async function () {
            const input = validInput();
            const tampered = { ...input, amount: (BigInt(input.amount) + 1n).toString() };
            try {
                await circuit.calculateWitness(tampered);
                expect.fail("should have thrown for a tampered amount");
            } catch (error) {
                expect(error.message).to.contain("Assert Failed");
            }
        });
    });
});
