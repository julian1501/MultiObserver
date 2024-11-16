function paddedL = padL(L,outputsID,numOutputs)
    % paddedL = padL(L,outputsID) returns the L matrix padded with zeros in
    % outputs that are not present in outputsID, numOutputs is the 
    % 
    % For example:
    %   - L = [2 1; 1 3; 5 1]
    %     outputsID = [1 3]
    %     numOriginalStates = 5
    %       -> paddedL = [2 0 1 0 0; 1 0 3 0 0; 5 0 1 0 0]
    
    numOriginalStates  = size(L,1);
    numObserverOutputs = size(L,2);
    paddedL = zeros(numOriginalStates,numOutputs);
    
    for i = 1:1:numObserverOutputs
        colId = outputsID(i);
        paddedL(:,colId) = L(:,i);
    end

end