function [Astar, Bstar, Cstar] = systemStarSetup(Abar,Bbar,AJ,BJ,LJ,CJ,sizeObserver,numObservers,numOriginalStates)
%     This function creates an block matrix A* that combines all J observers into
%     a single state space form.
    numStates = size(Abar,1);
    numInputs = size(BJ,2);
    numOutputs = size(CJ,1);
    
    
    % Nr = N + 1 because the original system does not count as one of the
    % outputs.
    AstarSize = numObservers + 1;    
    
    % Define Bstar
    Bstar = [Bbar; BJ];

    % Define LC as left row of Astar 
    diagLC = LJ*CJ;
    LC = diagLC(:,1:numStates);
    
    % Add LjCj from Aj and place on the diagonal
    for l = 1:1:numObservers
        Start = (l-1)*(numStates) + 1;
        End   = (l-1)*(numStates) + numStates;
        AJ(Start:End,Start:End) = AJ(Start:End,Start:End) + LC(Start:End,1:numStates);
    end
    
    Astar = [Abar, zeros(size(Abar,1),size(AJ,2)); -LC, AJ];
    
    % Define an element of Cstar for each subsystem of Astar
    CstarElement = zeros(1,numStates);
    CstarElement(:,1:numOriginalStates) = ones(1,numOriginalStates);
    
    Cstar = diag(repmat(CstarElement,1,AstarSize));
%     Cstar(1:Asize,1:Asize) = zeros(Asize,Asize);
end