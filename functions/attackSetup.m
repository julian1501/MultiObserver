function attack =  attackSetup(CMOstruct)
    % attack =  attackSetup(attackValue,CMOstruct) creates an array attack
    % that has the value of attackValue at the indices chosen in the
    % selectAB function.
    attackedOuptutsA = selectAB(CMOstruct);
    % loop over attacked outputs and add attack signal
    attack = zeros(CMOstruct.numOutputs,1);
    for i = 1:1:CMOstruct.numAttackedOutputs
        outputA = attackedOuptutsA(i);
        attack(outputA) = 1;
    end

end