function [Astar, Bstar, Cstar] = systemStarSetup(A,B,AJ,BJ,LJ,CJ,setString,CMOdict)
%     This function creates an block matrix A* that combines all J observers into
%     a single state space form.
    numOriginalStates = CMOdict("numOriginalStates");
    numOriginalInputs = CMOdict("numOriginalInputs");
    numOriginalOutputs = CMOdict("numOriginalOutputs");
    [numObservers, numOutputsObserver] = selectObserverSpecs(setString,CMOdict);
    
    % Nr = N + 1 because the original system does not count as one of the
    % outputs.
    AstarSize = numObservers + 1;    
    
    % Define Bstar
    Bstar = [B; BJ];
    LC = zeros(numOriginalStates*numObservers,numOriginalOutputs);

    % Add LjCj from Aj and place on the diagonal
    for l = 1:1:numObservers
        Start = (l-1)*(numOriginalStates) + 1;
        End   = (l-1)*(numOriginalStates) + numOriginalStates;
        LCl = LJ(Start:End,:)*CJ(:,Start:End);
        AJ(Start:End,Start:End) = AJ(Start:End,Start:End) + LCl;
        LC(Start:End,:) = LCl;
    end
    Astar = [A, zeros(numOriginalStates,numOriginalStates*numObservers);
            -LC, AJ];
    
    % Define an element of Cstar for each subsystem of Astar
    Cstar = eye(AstarSize*numOriginalStates);

end