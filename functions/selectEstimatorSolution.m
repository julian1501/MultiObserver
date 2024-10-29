function [solEst,solIndices] = selectEstimatorSolution(solJ,solP,solJIndices,solPIndices,CMOdict)
    % This function selects an estimator from the estimators in solSet
    % based on the following procedure.
    % For each Set define PiSet to be the largest deviation between the
    % estimate xSet and any estimate xSubset, where Subset is a subset of
    % Set. When there is no noise or attack signal all PiSets will be zero
    % and any J can be chosen. From all PiSet we chose the estimation from
    % the Set that has the smallest largest deviation.
    
    numStates = CMOdict('numOriginalStates');
    numJObservers = CMOdict('numJObservers');
    sizeJObservers = CMOdict('sizeJObservers');
    numPObservers = CMOdict('numPObservers');
    sizePObservers = CMOdict('sizePObservers');

    % remove first set of states: they are the system solution not an
    % observer estimation
    solJ        = solJ(numStates+1:end,:);
    solP        = solP(numStates+1:end,:);
    % find the number of timesteps
    numtstep = size(solJ,2);
    % Create the time series of the best estimate
    solEst = zeros(numStates,numtstep);

    % for each j, find the p's that are subsets of j
    % Define emtpy array that will store the indices of the rows of
    % solP that are subsets of solj. each row of PsubsetOfJIndices stores
    % the ids of p that are a subset. For exapmle
    numOfPsubsetsInJ = nchoosek(sizeJObservers,sizePObservers);
    PsubsetOfJIndices = zeros(numJObservers,numOfPsubsetsInJ);
    for j = 1:1:numJObservers
        soljIndices = solJIndices(j,:);
        % create new emtpy row to fill and append to the bottom of
        % PsubsetOfJIndices
        newRow = [];
        for p = 1:1:numPObservers
            solpIndices = solPIndices(p,:);
            isPSubset = isSubsetOf(soljIndices,solpIndices);
            % If the indices of p are a subset of those of j: find the
            if isPSubset
                newRow(1,end+1) = p;
            end
        end
        PsubsetOfJIndices(j,:) = newRow;
    end
    
    % Initialize PiJ, the array that will house all Pi j (the maximum
    % difference between a J observer and all its P observers).
    PiJ = zeros(numJObservers,1);
    % Loop over each timestep
    tstart = 1;
    if tstart == 2
        warning('Tstart is 2 during testing, this should be changed to 1 when really running the code.')
    end
    for t = tstart:1:numtstep
        % Loop over the J observer solutions
        for j = 1:1:numJObservers
            solj = solJ((j-1)*numStates+1:j*numStates,t);
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
                solp = solP((pIndex-1)*numStates+1:pIndex*numStates,t);
                % calculate and store the difference between solj and solp
                dif = norm(solj-solp,2);
                difflist(p,:) = dif;
                
            end

            % we now select Pi j as the maximum of this list
            Pij = max(difflist);
            PiJ(j,1) = Pij;
                    
        end

        % Select the extimate xj with j being the best smallest value
        % in PiJ
        jBestEst = find(PiJ==min(PiJ));
        BestEst = solJ((jBestEst-1)*numStates+1:jBestEst*numStates,t);
        % add BestEst to xEst
        solEst(1:numStates,t) = BestEst;
        
    end

    

end