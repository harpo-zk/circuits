const { buildBabyjub, buildPoseidon } = require("circomlibjs");
const { unstringifyBigInts } = require("ffjavascript").utils;

class CryptoUtils {
    constructor() {
        this.babyjub = null;
        this.poseidon = null;
    }

    async init() {
        if (!this.babyjub) {
            this.babyjub = await buildBabyjub();
        }
        if (!this.poseidon) {
            this.poseidon = await buildPoseidon();
        }
    }

    // Generate a random Baby Jubjub private key
    generatePrivateKey() {
        const privateKey = this.babyjub.F.random();
        return this.babyjub.F.toString(privateKey);
    }

    // Generate public key from private key
    generatePublicKey(privateKey) {
        const pubKey = this.babyjub.mulPointEscalar(this.babyjub.Base8, privateKey);
        return [
            this.babyjub.F.toString(pubKey[0]),
            this.babyjub.F.toString(pubKey[1])
        ];
    }

    // Generate key pair
    generateKeyPair() {
        const privateKey = this.generatePrivateKey();
        const publicKey = this.generatePublicKey(privateKey);
        return { privateKey, publicKey };
    }

    // Poseidon hash
    hash(inputs) {
        // Convert inputs to BigInt safely
        const bigIntInputs = inputs.map(input => {
            if (typeof input === 'string') {
                if (/^[0-9]+$/.test(input)) {
                    return BigInt(input);
                }
                // Convert non-numeric strings to their char codes sum
                return BigInt(input.split('').reduce((sum, char) => sum + char.charCodeAt(0), 0));
            }
            if (typeof input === 'number') {
                return BigInt(input);
            }
            return input;
        });
        return this.poseidon.F.toString(this.poseidon(bigIntInputs));
    }

    // Generate random field element
    randomField() {
        return this.babyjub.F.toString(this.babyjub.F.random());
    }

    // Generate array of random field elements
    randomFieldArray(length) {
        return Array.from({ length }, () => this.randomField());
    }

    // Generate valid message structure (15 elements)
    generateMessage() {
        const keyPair = this.generateKeyPair();
        const nonce = this.randomField();
        
        return [
            keyPair.publicKey[0],           // 0: public key x
            keyPair.publicKey[1],           // 1: public key y
            nonce,                          // 2: nonce
            this.randomField(),             // 3: random field
            this.randomField(),             // 4: random field
            "1",                            // 5: token type
            "1000",                         // 6: amount
            this.randomField(),             // 7: random field
            this.randomField(),             // 8: random field
            this.randomField(),             // 9: random field
            this.randomField(),             // 10: random field
            this.randomField(),             // 11: random field
            this.randomField(),             // 12: random field
            this.randomField(),             // 13: random field
            this.randomField()              // 14: random field
        ];
    }

    // Generate merkle tree siblings (simplified for testing)
    generateMerkleSiblings(depth = 16) {
        return Array.from({ length: depth }, () => this.randomField());
    }

    // Create valid amounts array
    generateAmounts(count, total = null) {
        if (count === 1) {
            return total ? [total.toString()] : ["1000"];
        }
        
        if (total) {
            const amounts = [];
            let remaining = BigInt(total);
            
            for (let i = 0; i < count - 1; i++) {
                const amount = remaining / BigInt(count - i);
                amounts.push(amount.toString());
                remaining -= amount;
            }
            amounts.push(remaining.toString());
            return amounts;
        }
        
        return Array.from({ length: count }, () => "1000");
    }
}

module.exports = CryptoUtils;