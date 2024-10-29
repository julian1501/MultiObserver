function bool = isSubsetOf(superset,subset)
    % This function checks wheterh subset is a subset of superset. Sets can
    % be vertical or horizontal arrays.
    % For example:
    %   isSubsetOf([1 2 3 4],[1 2]) = true
    %   isSubsetOf([1 2 3 4],[1 5]) = false
    %   isSubsetOf([1 2; 3 4],[1 3]) = error: superset is not 1-dimensional.
    %   isSubsetOf([1 2],[1 2 3]) = error: The subset is larger then the superset.

    % Transform superset into horizontal array.
    if size(superset,1) > 1 && size(superset,2) == 1
        superset = superset';
    elseif size(superset,1) > 1 && size(superset) > 1
        error('superset is not 1-dimensional.')
    end
    % Transform subset into horizontal array.
    if size(subset,1) > 1 && size(subset,2) == 1
        subset = subset';
    elseif size(subset,1) > 1 && size(subset) > 1
        error('subset is not 1-dimensional.')
    end

    % Check if subset is smaller or equal in size to superset
    sizeSubset = size(subset,2);
    sizeSuperset = size(superset,2);
    if sizeSubset > sizeSuperset
        error('The subset is larger then the superset.')
    end

    % Initialize bool as true
    bool = true;
    
    for l = 1:1:sizeSubset
        if ~isMemberOf(superset,subset(l))
            bool = false;
            break
        end
    end

end