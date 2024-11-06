function eta = etaSetup(setA,CJIndices,CPIndices,attackValue,CMOdict)
    % eta = etaSetup(setA,CJIndices,CPIndices,attackValue,noiseFactor,noisePower,CMOdict)
    % sets up the state-space system input eta, where eta = [u;v+tau;w]. u
    % is system input, v is sensor noise, tau is the attack signal and w is
    % the disturbance.

    
    numJObservers = CMOdict('numJObservers');
    numPObservers = CMOdict("numPObservers");
    numOutputsPObservers = CMOdict('numOutputsPObservers');
    numOutputsJObservers = CMOdict('numOutputsJObservers');
    numOriginalStates = CMOdict('numOriginalStates');
    numOriginalInputs = CMOdict("numOriginalInputs");

    % Generate u
    u = zeros(numOriginalInputs,1);

    % Generate N (m x tsize) sensor noise signals
    numJOuptuts = numJObservers*numOutputsJObservers;
    numPOutputs = numPObservers*numOutputsPObservers;
    v = zeros(numJOuptuts+numPOutputs,1);

    % Generate N (n x tsize) attack signals
    % Select which outputs will be attacked, form 2 subsets of numOutputs
    % sized n. the first subset will be denoted by a value of 1 and the
    % second by a value of 2.
    tau = zeros(numJOuptuts+numPOutputs,1);
    % Loop over J observers
    for j = 1:1:numJObservers
        % Loop over outputs of each J observer
        row = CJIndices(j,:);
        for k = 1:1:numOutputsJObservers
            outputID = row(k);
            if isMemberOf(setA,outputID)
                tau((j-1)*numOutputsJObservers+k,:) = attackValue;
            end

        end

    end
    
    for p = 1:1:numPObservers
        % Loop over outputs of each P observer
        row = CPIndices(p,:);
        for k = 1:1:numOutputsPObservers
            outputID = row(k);
            if isMemberOf(setA,outputID)
                tau(numJOuptuts + (p-1)*numOutputsPObservers+k,:) = attackValue;
            end

        end

    end

    % Generate an (n x tsize) process noise signal
    w = zeros(numOriginalStates,1);

    eta = [u;v+tau;w];
end