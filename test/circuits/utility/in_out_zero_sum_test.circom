pragma circom 2.2.0;

template InOutZeroSum(nInputs, nOutputs) {
    signal input inputAmounts[nInputs];
    signal input outputAmounts[nOutputs];
    
    var inputSum = 0;
    var outputSum = 0;
    
    for (var i = 0; i < nInputs; i++) {
        inputSum += inputAmounts[i];
    }
    
    for (var i = 0; i < nOutputs; i++) {
        outputSum += outputAmounts[i];
    }
    
    inputSum === outputSum;
}

component main = InOutZeroSum(2, 2);