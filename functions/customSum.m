function result = customSum(arr)
    % Custom summation function for arrayfun compatibility
    result = 0;
    for i = 1:numel(arr)
        result = result + arr(i);
    end
end