function [THE_A,THE_B] = THEsystemSetup(q,MOstruct)
    
    topA = -1.*q;
    bottomA = [eye(MOstruct.numOriginalStates-1) zeros(MOstruct.numOriginalStates-1,1)];
    Avalues = [topA; bottomA];
    I = eye(MOstruct.numOutputs);
    THE_A = kron(Avalues,I);

    Bvalues = [1; zeros(MOstruct.numOriginalStates-1,1)];
    THE_B = kron(Bvalues,I);

end