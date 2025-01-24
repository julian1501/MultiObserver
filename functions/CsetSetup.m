function [Cset,CsetIndices,setAttack] = CsetSetup(CN,Attack,aggregate_grouping,obj)
% CsetSetup Function
%
% The 'CsetSetup' function creates a 3D array ('Cset') that specifies
% subsets of observer output matrices from the larger matrix 'CN' for each 
% individual observer. It also generates 'CsetIndices', a matrix that 
% records the indices of rows from 'CN' used in each subset, and 
% 'setAttack', which maps attack signals to the selected outputs in each 
% subset. The behavior varies depending on whether the system is linear or 
% nonlinear.
%
% This documentation was written by ChatGPT.
%
% Syntax:
% -------
% '[Cset, CsetIndices, setAttack] = CsetSetup(CN, Attack, aggregate_grouping, obj)'
%
% Inputs:
% -------
% - 'CN' (matrix): The larger output matrix containing all possible 
%   observer outputs.
% - 'Attack' (attack object): The attack object containing attack details, 
%   particularly 'attackList'.
% - 'aggregate_grouping' (integer): The grouping parameter used in nonlinear systems 
%   to form strict sensor groups.
% - 'obj' (mo object): The system object, including details such as 
%   'sys.nx', 'sys.numMass', 'numOutputs', and 'numObservers'.
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
% For Linear Systems ('obj.sys.Linear = 1'):
% 1. The function computes all combinations of outputs (rows) from 'CN' 
%    that can form subsets of a specified size ('obj.numOutputsObservers').
% 2. 'CsetIndices' stores the row indices of 'CN' used in each subset.
% 3. 'Cset' and 'setAttack' are populated based on these combinations.
%
% For Nonlinear Systems ('obj.sys.Linear = 0'):
% 1. Sensor groups are created by aggregating related sensors (e.g., those 
%    measuring the same mass position).
% 2. Larger groups are formed based on 'aggregate_grouping', ensuring all 
%    outputs per observer are unique.
% 3. 'CsetIndices' is constructed to avoid duplicate rows within each subset.
% 4. Rows with duplicates are removed, and valid subsets are retained for 
%    further processing.
% 5. 'Cset' and 'setAttack' are built from these valid subsets.
%
% Notes:
% ------
% - 'nchoosek' is used for linear systems to compute all combinations.
% - Nonlinear systems rely on 'aggregate_grouping' and strict sensor pairings.
% - The function assumes 'Attack.attackList' and 'CN' have compatible 
%   dimensions.
%
% Dependencies:
% -------------
% - 'obj.sys.nx': The number of states in the system.
% - 'obj.sys.numMass': The number of masses in the system (for nonlinear systems).
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
            sensorGroups = combinations(sameSensors,aggregate_grouping);
            groupSize = size(sensorGroups,2);
            numSensorGroups = size(sensorGroups,1);
            % make large groups out of the sensorGroups  obj.numOutputsObservers/numSensorCopies
            CgroupIndices = nchoosek(1:1:numSensorGroups,obj.numOutputsObservers);
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
%                     CsetIndices(g,:) = zeros(1,CsetSize);
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