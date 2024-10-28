function CJ = CJSetup(CN,sizeObserver,numOutputs,numObservers)
    % This function sets up CJ, the C matrix with (N-M) sized sets J that
    % form a single observer. So, every (N-M) rows form a single observer
    % of the system.
    
    % Extract the number of states
    numStates = size(CN,2);

    % Define a list with all indices, so 1,2,...,N
    outputList = 1:1:numOutputs;
    
    % Select the indices of the combinations of Cj's
    CJIndices = nchoosek(outputList,sizeObserver);
    
    % Loop over the combinations and add them to the empty CJ
    CJ = zeros(numObservers*sizeObserver,numStates);
    for j = 1:1:numObservers
        % In every j of CJ
        selection = CJIndices(j,:);
        for k = 1:1:sizeObserver
            % in every row k of a Cj

            % Select first row of Cj
            rowId = (j-1)*sizeObserver + k;
            CNId = selection(k);
            CJ(rowId,:) = CN(CNId,:);
        end
    end

end