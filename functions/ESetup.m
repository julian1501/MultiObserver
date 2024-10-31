function E = ESetup(Bstar,LJ,setString,CMOdict)
    % This function defines the 'input-matrix' E based on the A,B and L
    % matrices of the system.
    numOriginalStates = CMOdict("numOriginalStates");
    numOriginalInputs = CMOdict("numOriginalInputs");
    numOriginalOutputs = CMOdict("numOriginalOutputs");
    [numObservers, numOutputsObserver] = selectObserverSpecs(setString,CMOdict);
    
    Esize1 = (numObservers+1)*numOriginalOutputs;
    Esize2 = numOriginalInputs + numObservers*(numOutputsObserver + numOriginalOutputs) + numOriginalOutputs;
    % Define the empty E matrix:
    %    Vertical: Esize1
    %    Horizontal: Number of inputs + (N x number of outputs per Cj) + n
    %       Number of outputs per Cj is 1 in current implementation, since
    %       a multiple output system is seen as a combination of different
    %       rows of CJ.
    E = zeros(Esize1,Esize2);
    
    % Add Bbar and Bbar to first column
    E(:,1:numOriginalInputs) = Bstar;
    
    % Add Lj's to central section
    for l = 1:1:numObservers
        rowStart = l*numOriginalStates+1;
        rowEnd   = l*numOriginalStates+1 + numOriginalStates-1;
        colStart = numOriginalInputs + (l-1)*numOutputsObserver + 1;
        colEnd   = numOriginalInputs + (l-1)*numOutputsObserver + numOutputsObserver;
        E(rowStart:rowEnd,colStart:colEnd) = -LJ((l-1)*numOriginalStates + 1:(l-1)*numOriginalStates + numOriginalStates ,:);
    end

    % Add -I to central part
    E(numOriginalStates+1:end,numOriginalInputs+numObservers*numOutputsObserver+1:end-numOriginalStates) = -eye(numOriginalStates*numObservers);

    % Add In to right top slice
    E(1:numOriginalStates,end-numOriginalStates+1:end) = eye(numOriginalStates);

end