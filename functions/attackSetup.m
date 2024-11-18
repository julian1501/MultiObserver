function attack =  attackSetup(attackValue,CMOstruct)
    % attack =  attackSetup(attackValue,CMOstruct) creates an array attack
    % that has the value of attackValue at the indices chosen in the
    % selectAB function.
    attackedOuptuts = selectAB(CMOstruct);
    % loop over attacked outputs and add attack signal
    attack = zeros(CMOstruct.numOutputs,1);
    for i = 1:1:CMOstruct.numAttackedOutputs
        output = attackedOuptuts(i);
        attack(output) = attackValue;
    end

end