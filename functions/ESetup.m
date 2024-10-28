function E = ESetup(Bstar,LJ,numObservers,sizeObserver,numOriginalStates)
    % This function defines the 'input-matrix' E based on the A,B and L
    % matrices of the system.
    numStatesObserver = sizeObserver*numOriginalStates;
    
    % n is the size of a single block in an observer
    numInputs = size(Bstar,2);
    numOutputs = size(LJ,2);
    Esize1 = (numObservers+1)*numStatesObserver;
    Esize2 = numInputs + numObservers*numOutputs + sizeObserver;
    % Define the empty E matrix:
    %    Vertical: Esize1
    %    Horizontal: Number of inputs + (N x number of outputs per Cj) + n
    %       Number of outputs per Cj is 1 in current implementation, since
    %       a multiple output system is seen as a combination of different
    %       rows of CJ.
    E = zeros(Esize1,Esize2);
    
    % Add Bbar and Bbar to first column
    E(:,1:numInputs) = Bstar;

    % Add Lj's to central section
    for l = 1:1:numObservers
        rowStart = l*numStatesObserver+1;
        rowEnd   = l*numStatesObserver+1 + numStatesObserver-1;
        colStart = numInputs + (l-1)*numOutputs + 1;
        colEnd   = numInputs + (l-1)*numOutputs + numOutputs ;
        E(rowStart:rowEnd,colStart:colEnd) = LJ((l-1)*numStatesObserver + 1:(l-1)*numStatesObserver + numStatesObserver ,:);
    end

    % Add In to right top slice
    E(1:sizeObserver,end-sizeObserver+1:end) = eye(sizeObserver);

end