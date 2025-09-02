const path = require("path");
const { expect } = require("chai");
const wasm_tester = require("circom_tester").wasm;
const CryptoUtils = require("../utils/crypto-utils");

describe("InOutZeroSum Circuit", function() {
    let circuit;
    let cryptoUtils;

    before(async function() {
        cryptoUtils = new CryptoUtils();
        await cryptoUtils.init();
        
        circuit = await wasm_tester(
            path.join(__dirname, "../circuits/utility/in_out_zero_sum_isolated.circom")
        );
    });

    describe("Valid zero-sum transactions", function() {
        it("should accept equal input and output sums", async function() {
            const input = {
                inValues: ["1000", "500"],
                outValues: ["750", "750"]
            };
            
            const witness = await circuit.calculateWitness(input);
            await circuit.checkConstraints(witness);
        });

        it("should accept single input/output balance", async function() {
            const input = {
                inValues: ["2000", "0"],
                outValues: ["1000", "1000"]
            };
            
            const witness = await circuit.calculateWitness(input);
            await circuit.checkConstraints(witness);
        });

        it("should accept large balanced amounts", async function() {
            const input = {
                inValues: ["1000000", "2000000"],
                outValues: ["1500000", "1500000"]
            };
            
            const witness = await circuit.calculateWitness(input);
            await circuit.checkConstraints(witness);
        });
    });

    describe("Invalid transactions", function() {
        it("should reject unbalanced transactions (more output)", async function() {
            const input = {
                inValues: ["1000", "500"],
                outValues: ["1000", "1000"]
            };
            
            try {
                await circuit.calculateWitness(input);
                expect.fail("Should have thrown an error for unbalanced transaction");
            } catch (error) {
                expect(error.message).to.contain("Assert Failed");
            }
        });

        it("should reject unbalanced transactions (more input)", async function() {
            const input = {
                inValues: ["2000", "1000"],
                outValues: ["1000", "500"]
            };
            
            try {
                await circuit.calculateWitness(input);
                expect.fail("Should have thrown an error for unbalanced transaction");
            } catch (error) {
                expect(error.message).to.contain("Assert Failed");
            }
        });

        it("should reject zero output values", async function() {
            const input = {
                inValues: ["1000", "500"],
                outValues: ["1500", "0"]
            };
            
            try {
                await circuit.calculateWitness(input);
                expect.fail("Should have thrown an error for zero output");
            } catch (error) {
                expect(error.message).to.contain("Assert Failed");
            }
        });
    });

    describe("Edge cases", function() {
        it("should handle minimum valid amounts", async function() {
            const input = {
                inValues: ["1", "1"],
                outValues: ["1", "1"]
            };
            
            const witness = await circuit.calculateWitness(input);
            await circuit.checkConstraints(witness);
        });

        it("should handle single large transaction", async function() {
            const input = {
                inValues: ["1000000", "0"],
                outValues: ["500000", "500000"]
            };
            
            const witness = await circuit.calculateWitness(input);
            await circuit.checkConstraints(witness);
        });
    });
});