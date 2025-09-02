const path = require("path");
const { expect } = require("chai");
const wasm_tester = require("circom_tester").wasm;
const CryptoUtils = require("../utils/crypto-utils");

describe("MintVerify Circuit", function() {
    let circuit;
    let cryptoUtils;

    before(async function() {
        cryptoUtils = new CryptoUtils();
        await cryptoUtils.init();
        
        circuit = await wasm_tester(
            path.join(__dirname, "../circuits/core/mint_verify_test.circom")
        );
    });

    describe("Valid mint operations", function() {
        it("should verify valid mint with positive amount", async function() {
            const amountR = "1000";
            
            const input = {
                amountR: amountR
            };
            
            const witness = await circuit.calculateWitness(input);
            await circuit.checkConstraints(witness);
            
            // Check outputs exist and are valid
            expect(witness[1]).to.exist; // commitment
            expect(witness[2]).to.exist; // nullifier
            expect(witness[1].toString()).to.not.equal("0");
            expect(witness[2].toString()).to.not.equal("0");
        });

        it("should verify mint with minimum amount", async function() {
            const amountR = "1";
            
            const input = {
                amountR: amountR
            };
            
            const witness = await circuit.calculateWitness(input);
            await circuit.checkConstraints(witness);
            
            // Check outputs exist
            expect(witness[1]).to.exist; // commitment
            expect(witness[2]).to.exist; // nullifier
        });

        it("should verify mint with large amount", async function() {
            const amountR = "1000000000";
            
            const input = {
                amountR: amountR
            };
            
            const witness = await circuit.calculateWitness(input);
            await circuit.checkConstraints(witness);
            
            // Check outputs exist
            expect(witness[1]).to.exist; // commitment
            expect(witness[2]).to.exist; // nullifier
        });
    });

    describe("Invalid mint operations", function() {
        it("should reject mint with zero amount", async function() {
            const amountR = "0";
            
            const input = {
                amountR: amountR
            };
            
            try {
                await circuit.calculateWitness(input);
                expect.fail("Should have thrown an error for zero amount");
            } catch (error) {
                expect(error.message).to.contain("Assert Failed");
            }
        });
    });

    describe("Output validation", function() {
        it("should produce consistent commitment output", async function() {
            const amountR = "5000";
            
            const input = {
                amountR: amountR
            };
            
            const witness1 = await circuit.calculateWitness(input);
            const witness2 = await circuit.calculateWitness(input);
            
            // Same inputs should produce same commitment
            const commitment1 = witness1[1]; // commitment output
            const commitment2 = witness2[1]; // commitment output
            
            expect(commitment1.toString()).to.equal(commitment2.toString());
        });

        it("should produce different commitments for different inputs", async function() {
            const amountR1 = "1000";
            const amountR2 = "2000";
            
            const input1 = { amountR: amountR1 };
            const input2 = { amountR: amountR2 };
            
            const witness1 = await circuit.calculateWitness(input1);
            const witness2 = await circuit.calculateWitness(input2);
            
            const commitment1 = witness1[1]; // commitment output
            const commitment2 = witness2[1]; // commitment output
            
            expect(commitment1.toString()).to.not.equal(commitment2.toString());
        });
    });
});