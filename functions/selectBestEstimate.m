function [bestStateEstimate, jBestEstimate] = selectBestEstimate(x,tsteps,PsubsetOfJIndices,numOfPsubsetsInJ,Jmo,Pmo,sys)
    % [bestEstimate, jBestEstimate] = 
    % selectBestEstimate(x,tsteps,PsubsetOfJIndices,CMOdict) selects the
    % best estimate bestStateEstimate (xhat) from subobservers OP out of J 
    % observers in the solution x for every time instant up to tsteps and 
    % returns the observer index j which provides the best estimate. The 
    % selection is made according to the criteria in (Chong, 2015, 
    % Observability of linear systems under adversarial attacks) and are as
    % follows:
    %   1. xhat(t) = xhat_sigma(t)_(t),
    %   2. sigma(t) = arg min PiJ(t)
    %   3. PiJ(t) = max |xhat_J(t) - xhat_P(t)| for each sub-observer P in
    %       J.
    %
    % For example:
    %   - x = [ 0.0011;
    %          -0.9476;
    %          -0.0329;
    %          -0.8780;
    %          -0.0755;
    %          -0.9336;
    %          -0.0478;
    %          -0.8991;
    %           0.0155;
    %          -0.7731;
    %          -0.2359;
    %          -0.1777;
    %          -0.0011;
    %          -0.8644]
    %     tsteps = 1
    %     PSubsetOfJIndices = [1 2; 1 3; 2 3]
    %       -> bestEstimate  = [-0.0755; -0.9336]
    %          jbestEstimate = 2


    % xJ contains the states of the J observers
    xJ = x(sys.nx+1:(1+Jmo.numObservers)*sys.nx,:);
    % xP contains the states of the P observers
    xP = x((1+Jmo.numObservers)*sys.nx+1:(1+Jmo.numObservers+Pmo.numObservers)*sys.nx,:);
    
    % Initialize PiJ, the array that will house all Pi j (the maximum
    % difference between a J observer and all its P observers).
    PiJ = zeros(Jmo.numObservers,1);

    % create emtpy array to store best estimate and which j supplies it
    bestStateEstimate = zeros(sys.nx,tsteps);
    jBestEstimate = zeros(1,tsteps);

    
    for t = 1:1:tsteps
        xJ3D = reshape(xJ(:,t),sys.nx,1,[]);
        xP3D = reshape(xP(:,t),sys.nx,1,[]);
        for j = 1:1:Jmo.numObservers
            xj = xJ3D(:,:,j);
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
                xp = xP3D(:,:,pIndex);
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
        bestEstimateTstep = xJ((jBestEstimateTstep-1)*sys.nx+1:jBestEstimateTstep*sys.nx,t);
        bestStateEstimate(:,t) = bestEstimateTstep;

    end

end