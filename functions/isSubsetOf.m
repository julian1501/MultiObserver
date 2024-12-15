function bool = isSubsetOf(superset,subset)
% isSubsetOf Function
%
% The 'isSubsetOf' function checks if one set (subset) is a subset of 
% another set (superset). It verifies if all elements of the subset exist 
% in the superset. The sets can be represented as either vertical or 
% horizontal arrays.
%
% Documentation written by ChatGPT.
%
% Syntax:
% -------
% bool = isSubsetOf(superset, subset)
%
% Inputs:
% -------
% - 'superset': A 1-dimensional array (either row or column vector) that 
%   represents the superset.
% - 'subset': A 1-dimensional array (either row or column vector) that 
%   represents the subset.
%
% Outputs:
% --------
% - 'bool': A logical value indicating whether the subset is contained 
%   within the superset:
%     - 'true': If the subset is a valid subset of the superset.
%     - 'false': If the subset is not a valid subset of the superset.
%     - An error is raised if the superset or subset are not 1-dimensional 
%       or if the subset is larger than the superset.
%
% Description:
% ------------
% This function first ensures that both the superset and the subset are 
% 1-dimensional arrays. It then checks if the subset is smaller than or 
% equal to the superset in size. If the subset is smaller or equal, it 
% proceeds to verify that every element of the subset is contained in the 
% superset using the 'isMemberOf' function. If any element of the subset is
% not found in the superset, the function returns 'false'. If the subset is
% larger than the superset, an error is raised.
%
% Example:
% --------
% Valid subset:
% superset = [1 2 3 4];
% subset = [1 2];
% bool = isSubsetOf(superset, subset);
% % bool will be true (subset is a valid subset of superset).
% 
% Invalid subset:
% superset = [1 2 3 4];
% subset = [1 5];
% bool = isSubsetOf(superset, subset);
% % bool will be false (subset contains an element not in superset).
% 
% Error due to non-1D array:
% superset = [1 2; 3 4];  % 2D array (error case)
% subset = [1 3];
% bool = isSubsetOf(superset, subset);
% % Error: superset is not 1-dimensional.
%
% Notes:
% ------
% - The function will raise an error if either the superset or the subset 
%   is not a 1-dimensional array.
% - The subset must not be larger than the superset.
% - The 'isMemberOf' function is used to check if each element of the 
%   subset exists in the superset.
%
% See also:
% ---------
% isMemberOf


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