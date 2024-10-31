function [Aset,LC] = systemStarSetup(Aset,Lset,Cset,setString,CMOdict)
%     This function creates an block matrix A* that combines all J observers into
%     a single state space form.
    numOriginalStates = CMOdict("numOriginalStates");
    numOriginalInputs = CMOdict("numOriginalInputs");
    numOriginalOutputs = CMOdict("numOriginalOutputs");
    [numObservers, numOutputsObserver] = selectObserverSpecs(setString,CMOdict);
    
    % Define Bstar
    LC = zeros(numOriginalStates*numObservers,numOriginalOutputs);

    % Add LjCj from Aj and place on the diagonal
    for l = 1:1:numObservers
        Start = (l-1)*(numOriginalStates) + 1;
        End   = (l-1)*(numOriginalStates) + numOriginalStates;
        LCl = Lset(Start:End,:)*Cset(:,Start:End);
        Aset(Start:End,Start:End) = Aset(Start:End,Start:End) + LCl;
        LC(Start:End,:) = LCl;
    end

end