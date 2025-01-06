function [bestStateEstimate, jBestEstimate] = sbeCPU(x,tsteps,PsubsetOfJIndices,numOfPsubsetsInJ,Jmo,Pmo,sys,wb)
% selectBestEstimate Function
%
% The 'selectBestEstimate' function determines the best state estimate 
% (xhat) from a set of subobservers P within J observers at each time step.
% The function identifies the observer index sigma(t) that provides the best
% estimate based on a predefined selection criterion, and returns the 
% corresponding state estimate and observer index for all time steps.
%
% Documentation written by ChatGPT.
%
% Inputs:
% -------
% - 'x': A matrix containing the combined state trajectories for all observers. 
%   The state trajectories are divided into:
%   1. J observer states
%   2. P observer states
%
% - 'tsteps': The number of time steps for which the state estimates are provided.
%
% - 'PsubsetOfJIndices': A matrix containing indices that map each J 
%   observer to its corresponding P subobservers.
%
% - 'numOfPsubsetsInJ': The number of P subobservers within each 
%   J observer.
%
% - 'Jmo': A structure containing information about the J observers, 
%   specifically:
%   - 'Jmo.numObservers': The total number of J observers.
%
% - 'Pmo': A structure containing information about the P observers, 
%   specifically:
%   - 'Pmo.numObservers': The total number of P observers.
%
% - 'sys': A structure containing system properties, including:
%   - 'sys.nx': The number of state variables for each observer.
%
% Outputs:
% --------
% - 'bestStateEstimate': A matrix of size n_x by tsteps containing the 
%   best state estimate at each time step.
%
% - 'jBestEstimate': A row vector of length 'tsteps' containing the index of 
%   the J observer that provided the best state estimate at each time step.
%
% Function Description:
% ---------------------
% The function follows these steps:
% 1. Extract the state trajectories of the J observers and P observers from 
%    'x'.
% 2. For each time step t:
%    a. Reshape the states of the J and P observers into 3D matrices for 
%       easier manipulation.
%    b. Loop through each J observer:
%       - Compute the maximum norm difference Pi_j between the 
%         J observer's state and the states of its corresponding 
%         P subobservers.
%    c. Identify the J observer with the minimum Pi_j
%       value and select its state as the best estimate for that time step.
% 3. Return the best state estimates and the corresponding observer indices.
%
% Selection Criterion:
% --------------------
% The selection is based on minimizing the observability degradation, 
% as described in Chong (2015):
% 1. The best estimate is defined as:
%    x_hat(t) = x_hat{_sigma(t)}(t)
%    where \sigma(t) is the observer index minimizing Pi_j(t).
% 2. Pi_j(t) is calculated as:
%    Pi_j(t) = max(x_hat_j(t) - x_hat_p(t))
%
% Example:
% --------
% Consider a system with n_x = 2, J = 3 observers, and P = 2
% subobservers. Given:
% - 'x': A matrix of size nx times tsteps containing state estimates 
%   for all observers.
% - 'PsubsetOfJIndices = [1 2; 1 3; 2 3]': Maps each J observer 
%   to its corresponding P subobservers.
% - 'tsteps = 1': Single time step.
%
% The output will provide:
% - 'bestStateEstimate': The best state estimate for t = 1.
% - 'jBestEstimate': The index of the J observer that provided 
%   the best estimate.
%
% Notes:
% ------
% - The function assumes that the input data is correctly formatted.
% - If multiple J observers have the same Pi_j value, 
%   the first observer (lowest index) is selected.
%
% See also:
% ---------
% norm, reshape, find



    % xJ contains the states of the J observers
    xJ = x(sys.nx+1:(1+Jmo.numObservers)*sys.nx,:);
    % xP contains the states of the P observers
    xP = x((1+Jmo.numObservers)*sys.nx+1:(1+Jmo.numObservers+Pmo.numObservers)*sys.nx,:);
    
    % Initialize PiJ, the array that will house all Pi j (the maximum
    % difference between a J observer and all its P observers).
    PiJ = gpuArray(zeros(Jmo.numObservers,1));

    % create emtpy array to store best estimate and which j supplies it
    bestStateEstimate = zeros(sys.nx,tsteps);
    jBestEstimate = zeros(1,tsteps);

    
    for t = 1:1:tsteps
        % update wait bar and catch exception if the user closed it
        try
            waitbar(t/tsteps,wb,sprintf('Selector is currently at timestep: %d/%d',t,tsteps))
        catch ME
            switch ME.identifier
                case 'MATLAB:waitbar:InvalidSecondInput'
                    error('User terminated the solver.')
                otherwise
                    rethrow(ME)
            end
    
        end

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