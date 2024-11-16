function eta = etaSetup(setA,CJIndices,CPIndices,attackValue,CMOstruct)
    % eta = etaSetup(setA,CJIndices,CPIndices,attackValue,noiseFactor,noisePower,CMOdict)
    % sets up the state-space system input eta, where eta = [u;v+tau;w]. u
    % is system input, v is sensor noise, tau is the attack signal and w is
    % the disturbance.

    % Generate u
    u = zeros(CMOstruct.numOriginalInputs,1);

    % Generate N (m x tsize) sensor noise signals
    numJOuptuts = CMOstruct.numJObservers*CMOstruct.numOutputsJObservers;
    numPOutputs = CMOstruct.numPObservers*CMOstruct.numOutputsPObservers;
    v = zeros(numJOuptuts+numPOutputs,1);

    % Generate N (n x tsize) attack signals
    % Select which outputs will be attacked, form 2 subsets of numOutputs
    % sized n. the first subset will be denoted by a value of 1 and the
    % second by a value of 2.
    tau = zeros(numJOuptuts+numPOutputs,1);
    % Loop over J observers
    for j = 1:1:CMOstruct.numJObservers
        % Loop over outputs of each J observer
        row = CJIndices(j,:);
        for k = 1:1:CMOstruct.numOutputsJObservers
            outputID = row(k);
            if isMemberOf(setA,outputID)
                tau((j-1)*CMOstruct.numOutputsJObservers+k,:) = attackValue;
            end

        end

    end
    
    for p = 1:1:CMOstruct.numPObservers
        % Loop over outputs of each P observer
        row = CPIndices(p,:);
        for k = 1:1:CMOstruct.numOutputsPObservers
            outputID = row(k);
            if isMemberOf(setA,outputID)
                tau(numJOuptuts + (p-1)*CMOstruct.numOutputsPObservers+k,:) = attackValue;
            end

        end

    end

    % Generate an (n x tsize) process noise signal
    w = zeros(CMOstruct.numOriginalStates,1);

    eta = [u;v+tau;w];
end