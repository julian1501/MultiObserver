function [bestEstimate, jBestEstimate] = selectBestEstimate(x,tsteps,PsubsetOfJIndices,CMOdict)
    % This function implements the selection algoritm as in Chong 2105
    % Linear systems under adverserial attacks.

    % Extract specs from CMOdict
    numOriginalStates = CMOdict('numOriginalStates');
    numJObservers = CMOdict('numJObservers');
    numPObservers = CMOdict('numPObservers');
    numOfPsubsetsInJ = CMOdict('numOfPsubsetsInJ');
    
    % xJ contains the states of the J observers
    xJ = x(numOriginalStates+1:(1+numJObservers)*numOriginalStates,:);
    % xP contains the states of the P observers
    xP = x((1+numJObservers)*numOriginalStates+1:(1+numJObservers+numPObservers)*numOriginalStates,:);
    
    % Initialize PiJ, the array that will house all Pi j (the maximum
    % difference between a J observer and all its P observers).
    PiJ = zeros(numJObservers,1);

    % create emtpy array to store best estimate and which j supplies it
    bestEstimate = zeros(numOriginalStates,tsteps);
    jBestEstimate = zeros(1,tsteps);
    
    for t = 1:1:tsteps
        for j = 1:1:numJObservers
            xj = xJ((j-1)*numOriginalStates+1:j*numOriginalStates,t);
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
                xp = xP((pIndex-1)*numOriginalStates+1:pIndex*numOriginalStates,t);
                % calculate and store the difference between solj and solp
                dif = norm(xj-xp);
                difflist(p,:) = dif;
                
            end
        
            % we now select Pi j as the maximum of this list
            Pij = max(difflist);
            PiJ(j,1) = Pij;
                    
        end
        
        % Select the extimate xj with j being the best smallest value
        % in PiJ
        jBestEstimateTstep = find(PiJ==min(PiJ));
        jBestEstimateTstep = jBestEstimateTstep(1);
        jBestEstimate(:,t) = jBestEstimateTstep;
        bestEstimateTstep = xJ((jBestEstimateTstep-1)*numOriginalStates+1:jBestEstimateTstep*numOriginalStates,t);
        bestEstimate(:,t) = bestEstimateTstep;

    end

end