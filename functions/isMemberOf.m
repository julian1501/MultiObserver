function bool = isMemberOf(superset,member)
% ISMEMBEROF Function
%
% The 'isMemberOf' function checks whether a specified 'member' is present 
% in the given 'superset'.
%
% Documentation written by ChatGPT.
%
% Syntax:
% -------
% bool = isMemberOf(superset, member)
%
% Inputs:
% -------
% - 'superset': A vector containing the set of elements to check against.
%     - Can be a row or column vector.
% - 'member': The element to check if it exists in the 'superset'.
%     - A single scalar value (numeric, string, etc.).
%
% Outputs:
% --------
% - 'bool': A logical value indicating whether the 'member' is in the 'superset':
%     - 'true': if the 'member' is found in the 'superset'.
%     - 'false': if the 'member' is not found in the 'superset'.
%
% Description:
% ------------
% This function iterates through the elements of the 'superset' and compares 
% each element to the 'member'. If the 'member' is found in the 'superset',
% the function returns 'true'. Otherwise, it returns 'false'. The function 
% uses a simple loop to check each element of the 'superset' for equality 
% with the 'member'.
%
% Example:
% --------
% Check if a number is in a set:
% superset = [1 2 3];
% member = 1;
% bool = isMemberOf(superset, member);
% bool = true
%
% Check if a number is not in a set:
% superset = [2 3 4];
% member = 1;
% bool = isMemberOf(superset, member);
% bool = false
%
% Notes:
% ------
% - This function compares the 'member' to each element in the 'superset' 
%   using equality ('=='). It may not work for non-scalar or complex types.
% - It assumes 'superset' is a vector (either row or column).
%
% See also:
% ---------
% ismember

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