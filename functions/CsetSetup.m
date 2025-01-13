function [Cset,CsetIndices,setAttack] = CsetSetup(CN,Attack,obj)
% CsetSetup Function
%
% The 'CsetSetup' function creates a 3D array ('Cset') that specifies
% subsets of observer output matrices from the larger matrix 'CN' for each 
% individual observer. It also generates 'CsetIndices', a matrix that 
% records the indices of rows from 'CN' used in each subset, and 
% 'setAttack', which maps attack signals to the selected outputs in each 
% subset. 
%
% This documentation was written by ChatGPT.
%
% Syntax:
% -------
% '[Cset, CsetIndices, setAttack] = CsetSetup(CN, Attack, obj)'
%
% Inputs:
% -------
% - 'CN' (matrix): The larger output matrix containing all possible 
%   observer outputs.
% - 'Attack' (attack object): The attack object containing attack details, 
%   particularly 'attackList'.
% - 'obj' (mo object): The system object, including details such as 
%   'sys.nx', 'numOutputs', and 'numObservers'.
%
% Outputs:
% --------
% - 'Cset' (3D array): A 3D array where each slice ('Cset(:,:,i)') is a 
%   subset of rows from 'CN' representing the outputs of an observer.
% - 'CsetIndices' (matrix): A 2D matrix where each row contains indices 
%   that specify which rows of 'CN' were used to construct the subsets in 
%   'Cset'.
% - 'setAttack' (3D array): A 3D array where each slice ('setAttack(:,:,i)') 
%   contains the attack signals corresponding to the outputs in 'Cset(:,:,i)'.
%
% Behavior:
% ---------
% 1. The function determines all combinations of outputs (rows) from 'CN' 
%    that can form subsets of a specified size ('numOutputsObservers').
% 2. It constructs 'Cset' by populating each slice with the rows of 'CN' 
%    corresponding to a specific combination.
% 3. 'CsetIndices' stores the row indices of 'CN' used in each subset.
% 4. 'setAttack' maps attack signals from 'Attack.attackList' to the rows 
%    of 'Cset' based on 'CsetIndices'.
%
% Example Scenarios:
% ------------------
% Inputs:
% - 'CN = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1];'
% - 'Attack.attackList = [1; 0; 1; 0];'
% - 'obj.numOutputs = 4; obj.numOutputsObservers = 3; obj.numObservers = 4;'
%
% Outputs:
% Cset(:,:,1) = [1 0 0 0; 0 1 0 0; 0 0 1 0];
% Cset(:,:,2) = [1 0 0 0; 0 1 0 0; 0 0 0 1];
% Cset(:,:,3) = [1 0 0 0; 0 0 1 0; 0 0 0 1];
% Cset(:,:,4) = [0 1 0 0; 0 0 1 0; 0 0 0 1];
%
% CsetIndices = [1 2 3; 1 2 4; 1 3 4; 2 3 4];
%
% setAttack(:,:,1) = [1; 0; 1];
% setAttack(:,:,2) = [1; 0; 0];
% setAttack(:,:,3) = [1; 1; 0];
% setAttack(:,:,4) = [0; 1; 0];
%
% Notes:
% ------
% - 'nchoosek' is used to compute all combinations of row indices.
% - The function assumes 'Attack.attackList' and 'CN' have compatible 
%   dimensions.
% - Observers are constructed iteratively, with each observer 
%   corresponding to a combination of rows from 'CN'.
%
% Dependencies:
% -------------
% - 'obj.sys.nx': The number of states in the system.
% - 'obj.numOutputs': The total number of outputs available.
% - 'obj.numObservers': The total number of observers.
% - 'obj.numOutputsObservers': The number of outputs per observer.

    

    % Extract the number of states
    numStates = obj.sys.nx;

    % Define a list with all indices, so 1,2,...,N
    outputList = 1:1:obj.numOutputs;
    
    switch obj.sys.Linear
        case 1 % linear system
            % Select the indices of the combinations of Cj's
            CsetIndices = nchoosek(outputList,obj.numOutputsObservers);

        case 0 % nonlinear system

            % create strict pairs
            % check if N_O / nx has no remainder
            if rem(obj.numOutputs,obj.sys.nx/2) ~= 0
                error("Strict pairs are not possible numOutputs =%2.0f and" + ...
                    " nx/2 =%3.0f, which leaves a remainder of%2.0f.", ...
                    obj.numOutputs,obj.sys.nx/2,rem(obj.numOutputs,obj.sys.nx))
            end
            
            % create correct pairs !! very dependent on reshape behaviour
            % each row contains all sensors measuring the same mass
            % position
            sameSensors = reshape(outputList,obj.sys.numMass,[],1);
            numSensorCopies = size(sameSensors,2);
            sensorGroups = combinations(sameSensors,'loose');
            groupSize = size(sensorGroups,2);
            numSensorGroups = size(sensorGroups,1);
            % make large groups out of the sensorGroups  obj.numOutputsObservers/numSensorCopies
            newObsvSize = max(min(numSensorCopies - Attack.numAttacks,obj.numOutputsObservers/obj.sys.numMass),1);
            CgroupIndices = nchoosek(1:1:numSensorGroups,newObsvSize);
            CsetSize = groupSize*size(CgroupIndices,2);
            CsetIndices = zeros(size(CgroupIndices,1),CsetSize);
            
            for g = 1:1:size(CgroupIndices,1)
                Cgroup = CgroupIndices(g,:);
                for i = 1:1:size(Cgroup,2)
                    CsetIndices(g,(i-1)*groupSize+1:i*groupSize) = sensorGroups(Cgroup(i),:);
                end
                
                % check for duplicates
                if size(unique(CsetIndices(g,:)),2) < CsetSize
                    % not unique
                    CsetIndices(g,:) = zeros(1,CsetSize);
                end
                

            end

            % select all rows that have nonzero elements
            rowsToKeep = any(CsetIndices,2);
            CsetIndices = CsetIndices(rowsToKeep,:);

    end

    % Loop over the combinations and add them to the empty CJ
    obj.numObservers = size(CsetIndices,1);
    Cset = zeros(size(CsetIndices,2),numStates,obj.numObservers);
    setAttack = zeros(size(CsetIndices,2),1,obj.numObservers);
    for j = 1:1:size(CsetIndices,1)
        % In every j of CJ
        Cselection = CsetIndices(j,:);
        Cset(:,:,j) = CN(Cselection,:);
        setAttack(:,:,j) = Attack.attackList(Cselection,:);       
    end

end