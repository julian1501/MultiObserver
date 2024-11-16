function E = ESetup(Bstar,LJ,LP,CMOdict)
    % This function defines the 'input-matrix' E based on the A,B and L
    % matrices of the system.
    numOriginalStates = CMOdict("numOriginalStates");
    numOriginalInputs = CMOdict("numOriginalInputs");
    numOriginalOutputs = CMOdict("numOriginalOutputs");
    numPObservers = CMOdict("numPObservers");
    numJObservers = CMOdict("numJObservers");
    numObservers = numPObservers+numJObservers;
    
    numOutputsJObservers = CMOdict("numOutputsJObservers");
    numOutputsPObservers = CMOdict("numOutputsPObservers");
    
    
    % Define the empty E matrix:
    %    Vertical: Esize1
    %    Horizontal: Number of inputs + (N x number of outputs per Cj) + n
    %       Number of outputs per Cj is 1 in current implementation, since
    %       a multiple output system is seen as a combination of different
    %       rows of CJ.
    Esize1 = (numObservers+1)*numOriginalStates;
    Esize2 = numOriginalInputs + numPObservers*numOutputsPObservers + numJObservers*numOutputsJObservers + numOriginalStates;
    E = zeros(Esize1,Esize2);
    
    % Add Bbar and Bbar to first column
    E(:,1:numOriginalInputs) = Bstar;
    
    % Add Lj's to central section
    for l = 1:1:numJObservers
        rowStart = l*numOriginalStates+1;
        rowEnd   = rowStart + numOriginalStates-1;
        colStart = numOriginalInputs + (l-1)*numOutputsJObservers + 1;
        colEnd   = colStart + numOutputsJObservers - 1;
        E(rowStart:rowEnd,colStart:colEnd) = -LJ(:,:,l);
    end
    % Add Lp's to central section
    for l = 1:1:numPObservers
        rowStart = (numJObservers+l)*numOriginalStates+1;
        rowEnd   = rowStart + numOriginalStates-1;
        colStart = numOriginalInputs + numJObservers*numOutputsJObservers + (l-1)*numOutputsPObservers + 1;
        colEnd   = colStart + numOutputsPObservers - 1;
        E(rowStart:rowEnd,colStart:colEnd) = -LP(:,:,l);
    end

    % Add In to right top slice
    E(1:numOriginalStates,end-numOriginalStates+1:end) = eye(numOriginalStates);

end