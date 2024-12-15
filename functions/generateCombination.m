function c = generateCombination(i, n, k)
    % cgen returns the i-th combination of k numbers chosen from 1,2,...,n
    % Input:
    %   i - the index of the combination (1-based indexing)
    %   n - total number of items
    %   k - number of items to choose
    % Output:
    %   c - the i-th combination as a row vector

    c = []; % Initialize the combination array
    r = i;  % Initialize the remaining index
    j = 0;  % Initialize starting point for the combination
    
    for s = 1:k
        cs = j + 1;
        while r - nchoosek(n - cs, k - s) > 0
            r = r - nchoosek(n - cs, k - s);
            cs = cs + 1;
        end
        c = [c, cs]; % Append the current selection
        j = cs;      % Update the starting point
    end
end
