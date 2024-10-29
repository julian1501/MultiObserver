function bool = isMemberOf(superset,member)
    % This function checks wheter member is a member of superset.
    % For example:
    % isMemberOf([1 2 3], 1) = true
    % isMemberOf([2 3 4], 2) = false
    sizeSuperset = size(superset,2);
    % Initialize bool as false
    bool = false;
    for l = 1:1:sizeSuperset
        if member == superset(l)
            bool = true;
            break
        end
    end
end