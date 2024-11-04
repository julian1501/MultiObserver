function [numOfPsubsetsInJ, PsubsetOfJIndices] = findIndices(CJIndices,CPIndices,CMOdict)
    % [numOfPsubsetsInJ, PsubsetOfJIndices] = 
    % findIndices(CJIndices,CPIndices,CMOdict) takes in two matrices with
    % indices of observers. It finds which observers of the smaller set P
    % are subsets of observers of the larger set J.
    %
    % For example:
    %   - CJIndices = [1 2 3; 1 2 4; 1 3 4; 2 3 4]
    %     CPIndices = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4];
    %       -> numOfPsubsetsInJ = 3
    %          PsubsetOfJIndices = [1 2 4;
    %                               1 3 5;
    %                               2 3 6;
    %                               4 5 6]
    
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