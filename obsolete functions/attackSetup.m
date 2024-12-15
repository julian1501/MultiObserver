function attack =  attackSetup(CMOstruct)
    % attack =  attackSetup(attackValue,CMOstruct) creates an array attack
    % that has the value of attackValue at the indices chosen in the
    % selectAB function.
    attackedOutputsA = selectAB(CMOstruct);
    fprintf('The attacked outputs are: \n')
    disp(attackedOutputsA)
    % loop over attacked outputs and add attack signal
    attack = zeros(CMOstruct.numOutputs,1);
    for i = 1:1:CMOstruct.numAttackedOutputs
        outputA = attackedOutputsA(i);
        attack(outputA) = 1;
    end

end