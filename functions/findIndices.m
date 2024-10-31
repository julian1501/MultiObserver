function [numOfPsubsetsInJ, PsubsetOfJIndices] = findIndices(CJIndices,CPIndices,CMOdict)
    % for each j, find the p's that are subsets of j
    % Define emtpy array that will store the indices of the rows of
    % solP that are subsets of solj. each row of PsubsetOfJIndices stores
    % the ids of p that are a subset. For exapmle
    
    % numOutputsJObservers, numOutputsPObservers, numJObservers, numPObservers
    numOutputsJObservers = CMOdict("numOutputsJObservers");
    numOutputsPObservers = CMOdict("numOutputsPObservers");
    numJObservers = CMOdict("numJObservers");
    numPObservers = CMOdict("numPObservers");

    numOfPsubsetsInJ = nchoosek(numOutputsJObservers,numOutputsPObservers);
    PsubsetOfJIndices = zeros(numJObservers,numOfPsubsetsInJ);



    for j = 1:1:numJObservers
        CjIndices = CJIndices(j,:);
        % create new emtpy row to fill and append to the bottom of
        % PsubsetOfJIndices
        newRow = [];
        for p = 1:1:numPObservers
            CpIndices = CPIndices(p,:);
            isPSubset = isSubsetOf(CjIndices,CpIndices);
            % If the indices of p are a subset of those of j: find the
            if isPSubset
                newRow(1,end+1) = p;
            end
        end
        PsubsetOfJIndices(j,:) = newRow;
    end
end