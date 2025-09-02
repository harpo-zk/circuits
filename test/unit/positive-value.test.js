const path = require("path");
const { expect } = require("chai");
const wasm_tester = require("circom_tester").wasm;
const CryptoUtils = require("../utils/crypto-utils");

describe("PositiveValues Circuit", function() {
    let circuit;
    let cryptoUtils;

    before(async function() {
        cryptoUtils = new CryptoUtils();
        await cryptoUtils.init();
        
        circuit = await wasm_tester(
            path.join(__dirname, "../circuits/utility/positive_value_isolated.circom")
        );
    });

    describe("Valid positive values", function() {
        it("should accept all positive values", async function() {
            const input = {
                values: ["100", "250", "1000"]
            };
            
            const witness = await circuit.calculateWitness(input);
            await circuit.checkConstraints(witness);
        });

        it("should accept single positive value", async function() {
            const input = {
                values: ["1", "1", "1"]
            };
            
            const witness = await circuit.calculateWitness(input);
            await circuit.checkConstraints(witness);
        });

        it("should accept maximum 64-bit values", async function() {
            const maxValue = (BigInt(2) ** BigInt(63) - BigInt(1)).toString();
            const input = {
                values: [maxValue, "1000", "500"]
            };
            
            const witness = await circuit.calculateWitness(input);
            await circuit.checkConstraints(witness);
        });
    });

    describe("Invalid values", function() {
        it("should reject zero values", async function() {
            const input = {
                values: ["100", "0", "1000"]
            };
            
            try {
                await circuit.calculateWitness(input);
                expect.fail("Should have thrown an error for zero value");
            } catch (error) {
                expect(error.message).to.contain("Assert Failed");
            }
        });

        it("should reject all zero values", async function() {
            const input = {
                values: ["0", "0", "0"]
            };
            
            try {
                await circuit.calculateWitness(input);
                expect.fail("Should have thrown an error for zero values");
            } catch (error) {
                expect(error.message).to.contain("Assert Failed");
            }
        });
    });

    describe("Edge cases", function() {
        it("should handle mixed valid values", async function() {
            const input = {
                values: ["1", "999999", "123456789"]
            };
            
            const witness = await circuit.calculateWitness(input);
            await circuit.checkConstraints(witness);
        });
    });
});