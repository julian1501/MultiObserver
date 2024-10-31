function bestEstimate = selectBestEstimate(x,PsubsetOfJIndices,CMOdict)
    % This function implements the selection algoritm as in Chong 2105
    % Linear systems under adverserial attacks.

    % Extract specs from CMOdict
    numOriginalStates = CMOdict('numOriginalStates');
    numJObservers = CMOdict('numJObservers');
    numPObservers = CMOdict('numPObservers');
    numOfPsubsetsInJ = CMOdict('numOfPsubsetsInJ');
    
    % first 4 states are the previous best 
    oldBestEst = x(1:numOriginalStates);
    % xtrue is the true response
    xtrue = x(numOriginalStates+1:end,:);
    % xJ contains the states of the J observers
    xJ = x(2*numOriginalStates+1:(2+numJObservers)*numOriginalStates);
    % xP contains the states of the P observers
    xP = x((2+numJObservers)*numOriginalStates+1:(2+numJObservers+numPObservers)*numOriginalStates);
    
    % Initialize PiJ, the array that will house all Pi j (the maximum
    % difference between a J observer and all its P observers).
    PiJ = zeros(numJObservers,1);

    for j = 1:1:numJObservers
        xj = xJ((j-1)*numOriginalStates+1:j*numOriginalStates,:);
        % select the row of PsubsetOfJIndices that contains the ids of
        % p that are a subset of J
        pSubsetofjIndices = PsubsetOfJIndices(j,:);
        % diflist will store the difference between solj and all its
        % subsets solp
        difflist = zeros(numOfPsubsetsInJ,1);
        % Loop over the P observers that are a subset of j
        for p = 1:1:numOfPsubsetsInJ
            % select the index of p that will be checked
            pIndex = pSubsetofjIndices(p);
            % select the solution of p that corresponds to this index
            xp = xP((pIndex-1)*numOriginalStates+1:pIndex*numOriginalStates,:);
            % calculate and store the difference between solj and solp
            dif = norm(xj-xp,2);
            difflist(p,:) = dif;
            
        end
    
        % we now select Pi j as the maximum of this list
        Pij = max(difflist);
        PiJ(j,1) = Pij;
                
    end
    
    % Select the extimate xj with j being the best smallest value
    % in PiJ
    jBestEst = find(PiJ==min(PiJ));
    bestEstimate = xJ((jBestEst-1)*numOriginalStates+1:jBestEst*numOriginalStates,:);

end