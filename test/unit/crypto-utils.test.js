const { expect } = require("chai");
const CryptoUtils = require("../utils/crypto-utils");

describe("CryptoUtils", function() {
    let cryptoUtils;

    before(async function() {
        this.timeout(30000); // Give more time for crypto init
        cryptoUtils = new CryptoUtils();
        await cryptoUtils.init();
    });

    describe("Key generation", function() {
        it("should generate valid private key", function() {
            const privateKey = cryptoUtils.generatePrivateKey();
            expect(privateKey).to.be.a('string');
            expect(privateKey).to.not.be.empty;
        });

        it("should generate valid public key from private key", function() {
            const privateKey = cryptoUtils.generatePrivateKey();
            const publicKey = cryptoUtils.generatePublicKey(privateKey);
            
            expect(publicKey).to.be.an('array');
            expect(publicKey).to.have.length(2);
            expect(publicKey[0]).to.be.a('string');
            expect(publicKey[1]).to.be.a('string');
        });

        it("should generate complete key pair", function() {
            const keyPair = cryptoUtils.generateKeyPair();
            
            expect(keyPair).to.have.property('privateKey');
            expect(keyPair).to.have.property('publicKey');
            expect(keyPair.publicKey).to.have.length(2);
        });

        it("should generate different key pairs", function() {
            const keyPair1 = cryptoUtils.generateKeyPair();
            const keyPair2 = cryptoUtils.generateKeyPair();
            
            expect(keyPair1.privateKey).to.not.equal(keyPair2.privateKey);
            expect(keyPair1.publicKey[0]).to.not.equal(keyPair2.publicKey[0]);
        });
    });

    describe("Hash functions", function() {
        it("should generate valid Poseidon hash", function() {
            const hash1 = cryptoUtils.hash(["123", "456"]);
            expect(hash1).to.be.a('string');
            expect(hash1).to.not.be.empty;
        });

        it("should generate consistent hashes", function() {
            const input = ["test", "data"];
            const hash1 = cryptoUtils.hash(input);
            const hash2 = cryptoUtils.hash(input);
            
            expect(hash1).to.equal(hash2);
        });

        it("should generate different hashes for different inputs", function() {
            const hash1 = cryptoUtils.hash(["input1"]);
            const hash2 = cryptoUtils.hash(["input2"]);
            
            expect(hash1).to.not.equal(hash2);
        });
    });

    describe("Random field generation", function() {
        it("should generate random field element", function() {
            const field1 = cryptoUtils.randomField();
            const field2 = cryptoUtils.randomField();
            
            expect(field1).to.be.a('string');
            expect(field2).to.be.a('string');
            expect(field1).to.not.equal(field2);
        });

        it("should generate array of random fields", function() {
            const fields = cryptoUtils.randomFieldArray(5);
            
            expect(fields).to.be.an('array');
            expect(fields).to.have.length(5);
            fields.forEach(field => {
                expect(field).to.be.a('string');
            });
        });
    });

    describe("Message generation", function() {
        it("should generate valid 15-element message", function() {
            const message = cryptoUtils.generateMessage();
            
            expect(message).to.be.an('array');
            expect(message).to.have.length(15);
            
            // Check that amount (index 6) is positive
            expect(parseInt(message[6])).to.be.greaterThan(0);
            
            // Check that token type (index 5) is set
            expect(message[5]).to.equal("1");
        });

        it("should generate different messages", function() {
            const message1 = cryptoUtils.generateMessage();
            const message2 = cryptoUtils.generateMessage();
            
            // Messages should be different (at least the nonce)
            expect(message1[2]).to.not.equal(message2[2]);
        });
    });

    describe("Merkle utilities", function() {
        it("should generate merkle siblings array", function() {
            const siblings = cryptoUtils.generateMerkleSiblings(16);
            
            expect(siblings).to.be.an('array');
            expect(siblings).to.have.length(16);
            
            siblings.forEach(sibling => {
                expect(sibling).to.be.a('string');
            });
        });

        it("should generate different siblings for different calls", function() {
            const siblings1 = cryptoUtils.generateMerkleSiblings(10);
            const siblings2 = cryptoUtils.generateMerkleSiblings(10);
            
            expect(siblings1).to.not.deep.equal(siblings2);
        });
    });

    describe("Amount generation", function() {
        it("should generate single amount", function() {
            const amounts = cryptoUtils.generateAmounts(1);
            
            expect(amounts).to.be.an('array');
            expect(amounts).to.have.length(1);
            expect(amounts[0]).to.equal("1000");
        });

        it("should generate balanced amounts", function() {
            const amounts = cryptoUtils.generateAmounts(3, "3000");
            
            expect(amounts).to.have.length(3);
            
            const total = amounts.reduce((sum, amount) => sum + BigInt(amount), BigInt(0));
            expect(total.toString()).to.equal("3000");
        });

        it("should generate default amounts", function() {
            const amounts = cryptoUtils.generateAmounts(2);
            
            expect(amounts).to.have.length(2);
            amounts.forEach(amount => {
                expect(amount).to.equal("1000");
            });
        });
    });
});