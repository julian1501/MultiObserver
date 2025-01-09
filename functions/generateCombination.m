function combinations = generateCombination(Id, n, k)
    % cgen returns the i-th combination of k numbers chosen from 1,2,...,n
    % Input:
    %   Id - the index of the combination (1-based indexing)
    %   n - total number of items
    %   k - number of items to choose
    % Output:
    %   c - the i-th combination as a row vector

    combinations = zeros(1,k); % Initialize the combination array
    remaining = Id;  % Initialize the remaining index
    init = 0;  % Initialize starting point for the combination
    
    for s = 1:k
        cs = init + 1;
        while remaining - nchoosek(n - cs, k - s) > 0
            remaining = remaining - nchoosek(n - cs, k - s);
            cs = cs + 1;
        end
        combinations(s) = cs; % Append the current selection
        init = cs;      % Update the starting point
    end
end
