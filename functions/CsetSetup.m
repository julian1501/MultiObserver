function [Cset,CsetIndices] = CsetSetup(CN,setString,CMOdict)
    % [Cset, CsetIndices] =
    % CsetSetup(CN,sizeObserver,numOutputs,numObservers) sets up a matrix
    % with all observers with outputs a subset of CN. The cardinality of
    % this subset is sizeObserver and numObservers indicates the amount of
    % subsets that are made. CsetIndices is a matrix where each row stored
    % the indices of the observers that make up a subset.
    %
    % For example:
    %   - CN = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1] & numObservers = 4 &
    %     numOutputsObserver = 3
    %       -> Cset = [1 0 0 0;
    %                  0 1 0 0;
    %                  0 0 1 0;
    %                  1 0 0 0;
    %                  0 1 0 0;
    %                  0 0 0 1;
    %                  1 0 0 0;
    %                  0 0 1 0;
    %                  0 0 0 1;
    %                  0 1 0 0;
    %                  0 0 1 0;
    %                  0 0 0 1]
    %       -> CsetIndices = [1 2 3; 1 2 4; 1 3 4; 2 3 4];
    

    % Extract values from CMOdict
    numOutputs = CMOdict("numOutputs");
    [numObservers, numOutputsObserver] = selectObserverSpecs(setString,CMOdict);

    % Extract the number of states
    numStates = size(CN,2);

    % Define a list with all indices, so 1,2,...,N
    outputList = 1:1:numOutputs;
    
    % Select the indices of the combinations of Cj's
    CsetIndices = nchoosek(outputList,numOutputsObserver);
    
    % Loop over the combinations and add them to the empty CJ
    Cset = zeros(numOutputsObserver,numStates,numObservers);
    for j = 1:1:numObservers
        % In every j of CJ
        selection = CsetIndices(j,:);
        for k = 1:1:numOutputsObserver
            % in every row k of a Cj

            % Select first row of Cj
            CNId = selection(k);
            Cset(k,:,j) = CN(CNId,:);
        end

    end

end