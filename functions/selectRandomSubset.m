function subset = selectRandomSubset(set,subsetSize)
    % Selects a random subset of size subsetSize out of the provided set.
    % No duplicate choices, for example:
    %   if set = [1 2 3 4] and subsetSize = 3,
    %   the subset [1 3 3] is not possible.

    % choose indices to take randomly
    setSize = size(set,2);
    indices = randperm(setSize,subsetSize);
    % loop through indices and add it to subset matrix
    subset = zeros(1,subsetSize);
    for index = 1:1:subsetSize
        subset(1,index) = set(1,indices(1,index));
    end
end