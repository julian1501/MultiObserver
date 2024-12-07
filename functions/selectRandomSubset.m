function [subset,remainder] = selectRandomSubset(set,subsetSize)
    % [subset,remainder] = selectRandomSubset(set,subsetSize) selects a
    % random subset sized subsetSize out of set. The remainder is whatever
    % is not chosen.
    %
    % For example:
    %   - set = [1,2,3,4]
    %     subsetSize = 2
    %       -> subset = [1,3]
    %          remainder = [2,4]

    % choose indices to take randomly
    setSize = size(set,2);
    indices = randperm(setSize,subsetSize);
    % loop through indices and add it to subset matrix
    subset = zeros(1,subsetSize);
    for index = 1:1:subsetSize
        subset(1,index) = set(1,indices(1,index));
    end
    remainder = setdiff(set,subset);
end