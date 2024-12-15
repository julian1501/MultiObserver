function E = ESetup(Bstar,LJ,LP,CMOstruct)
    % This function defines the 'input-matrix' E based on the A,B and L
    % matrices of the system.
    numObservers = CMOstruct.numPObservers+CMOstruct.numJObservers;    
    
    % Define the empty E matrix:
    %    Vertical: Esize1
    %    Horizontal: Number of inputs + (N x number of outputs per Cj) + n
    %       Number of outputs per Cj is 1 in current implementation, since
    %       a multiple output system is seen as a combination of different
    %       rows of CJ.
    Esize1 = (numObservers+1)*CMOstruct.numOriginalStates;
    Esize2 = CMOstruct.numOriginalInputs + CMOstruct.numPObservers*CMOstruct.numOutputsPObservers + CMOstruct.numJObservers*CMOstruct.numOutputsJObservers + CMOstruct.numOriginalStates;
    E = zeros(Esize1,Esize2);
    
    % Add Bbar and Bbar to first column
    E(:,1:CMOstruct.numOriginalInputs) = Bstar;
    
    % Add Lj's to central section
    for l = 1:1:CMOstruct.numJObservers
        rowStart = l*CMOstruct.numOriginalStates+1;
        rowEnd   = rowStart + CMOstruct.numOriginalStates-1;
        colStart = CMOstruct.numOriginalInputs + (l-1)*CMOstruct.numOutputsJObservers + 1;
        colEnd   = colStart + CMOstruct.numOutputsJObservers - 1;
        E(rowStart:rowEnd,colStart:colEnd) = -LJ(:,:,l);
    end
    % Add Lp's to central section
    for l = 1:1:CMOstruct.numPObservers
        rowStart = (CMOstruct.numJObservers+l)*CMOstruct.numOriginalStates+1;
        rowEnd   = rowStart + CMOstruct.numOriginalStates-1;
        colStart = CMOstruct.numOriginalInputs + CMOstruct.numJObservers*CMOstruct.numOutputsJObservers + (l-1)*CMOstruct.numOutputsPObservers + 1;
        colEnd   = colStart + CMOstruct.numOutputsPObservers - 1;
        E(rowStart:rowEnd,colStart:colEnd) = -LP(:,:,l);
    end

    % Add In to right top slice
    E(1:CMOstruct.numOriginalStates,end-CMOstruct.numOriginalStates+1:end) = eye(CMOstruct.numOriginalStates);

end