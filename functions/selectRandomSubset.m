function [subset,remainder] = selectRandomSubset(set,subsetSize)
% selectRandomSubset Function
%
% The 'selectRandomSubset' function selects a random subset of specified 
% size from a given set and returns both the subset and the remaining 
% elements of the set.
%
% Documentation written by ChatGPT.
%
% Inputs:
% -------
% - 'set': A row vector containing the elements of the set from which a 
%   subset will be selected.
% - 'subsetSize': The number of elements to include in the randomly 
%   selected subset.
%
% Outputs:
% --------
% - 'subset': A row vector containing the randomly selected elements 
%   (subset of the input 'set') of size 'subsetSize'.
% - 'remainder': A row vector containing the elements of the input 'set' 
%   that were not selected as part of the subset.
%
% Function Description:
% ---------------------
% 1. The function determines the total number of elements in the input 
%    'set' using 'size'.
% 2. It generates a random permutation of indices from the set using 
%    'randperm' and selects the first 'subsetSize' indices to define 
%    the subset.
% 3. The subset is extracted from the input set based on the selected 
%    random indices.
% 4. The 'setdiff' function is used to compute the elements of the 
%    input 'set' that were not included in the subset, forming the remainder.
%
% Example:
% --------
% Given:
% - 'set = [1, 2, 3, 4]'
% - 'subsetSize = 2'
%
% A possible output could be:
% - 'subset = [1, 3]'
% - 'remainder = [2, 4]'
%
% Notes:
% ------
% - The function assumes that the input 'set' is a row vector.
% - 'subsetSize' must be less than or equal to the total number of 
%   elements in 'set'. An error will occur otherwise.
% - The random selection process ensures a unique subset for each 
%   function call, provided the random number generator state changes.
%
% Error Handling:
% ---------------
% - Ensure that 'subsetSize' does not exceed the size of the input 'set'.
%   Otherwise, the function will throw an error.
%
% Implementation Steps:
% ---------------------
% 1. Determine the size of the input 'set' ('setSize').
% 2. Use 'randperm' to generate a random permutation of indices and 
%    select the first 'subsetSize' indices.
% 3. Extract the elements corresponding to the selected indices 
%    from 'set' to form the 'subset'.
% 4. Use 'setdiff' to determine the 'remainder'.
%
% See also:
% ---------
% randperm, setdiff

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