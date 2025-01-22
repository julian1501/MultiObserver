function [numOfPsubsetsInJ, PsubsetOfJIndices] = findIndices(Jmo,Pmo)
% findIndices Function
%
% The 'findIndices' function determines which observers from a smaller set 
% ('Pmo') are subsets of observers from a larger set ('Jmo'). The function 
% returns the count of such subsets and their corresponding indices.
%
% Documentation written by ChatGPT.
%
% Syntax:
% -------
% '[numOfPsubsetsInJ, PsubsetOfJIndices] = findIndices(Jmo, Pmo, sys)'
%
% Inputs:
% -------
% - 'Jmo': Structure representing the larger observer set, containing:
%    - 'numOutputsObservers': Number of outputs per observer in 'Jmo'.
%    - 'numObservers': Number of observers in 'Jmo'.
%    - 'CiIndices': Matrix of observer indices for 'Jmo' (each row 
%      corresponds to an observer's indices).
% - 'Pmo': Structure representing the smaller observer set, containing:
%    - 'numOutputsObservers': Number of outputs per observer in 'Pmo'.
%    - 'numObservers': Number of observers in 'Pmo'.
%    - 'CiIndices': Matrix of observer indices for 'Pmo' (each row 
%      corresponds to an observer's indices).
% - 'sys': System object (optional; not directly used in this implementation).
%
% Outputs:
% --------
% - 'numOfPsubsetsInJ': Number of subsets in 'Pmo' that are contained within 
%   each observer in 'Jmo' (scalar).
% - 'PsubsetOfJIndices': Matrix of size '(Jmo.numObservers x numOfPsubsetsInJ)', 
%   where each row lists the indices of 'Pmo' observers that are subsets 
%   of the corresponding 'Jmo' observer.
%
% Description:
% ------------
% For each observer in 'Jmo', the function identifies the observers in 
% 'Pmo' whose indices are subsets of the 'Jmo' observer's indices.
%
% Example:
% --------
% Inputs:
% - 'Jmo.CiIndices = [1 2 3; 1 2 4; 1 3 4; 2 3 4]'
% - 'Pmo.CiIndices = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4]'
% - 'Jmo.numOutputsObservers = 3', 'Pmo.numOutputsObservers = 2'
% - 'Jmo.numObservers = 4', 'Pmo.numObservers = 6'
%
% Outputs:
% - 'numOfPsubsetsInJ = 3'
% - 'PsubsetOfJIndices = [1 2 4;
%                          1 3 5;
%                          2 3 6;
%                          4 5 6]'
%
% Algorithm:
% ----------
% 1. Compute the total number of subsets ('numOfPsubsetsInJ') using the 
%    'nchoosek' function.
% 2. Iterate over all observers in 'Jmo':
%    - For each observer, check if the indices of each observer in 'Pmo' 
%      are a subset.
%    - If a subset is found, append its index to the current row.
% 3. Store the indices of subsets in 'PsubsetOfJIndices'.
%
% Notes:
% ------
% - The isSubsetOf.m function must be defined to check whether one set 
%   of indices is a subset of another.
% - The function assumes that the observer indices in 'CiIndices' are 
%   sorted and unique.
%
% Dependencies:
% -------------
% - isSubsetOf.m: Utility function to check subset relations.
%
% See also:
% ---------
% - nchoosek.m: MATLAB function for combinations.
% - isSubsetOf.m: Custom subset-checking function.

    PsubsetOfJIndices = zeros(Jmo.numObservers,1);

    for j = 1:1:Jmo.numObservers
        CjIndices = Jmo.CiIndices(j,:);
        % create new emtpy row to fill and append to the bottom of
        % PsubsetOfJIndices
        newRow = [];
        for p = 1:1:Pmo.numObservers
            CpIndices = Pmo.CiIndices(p,:);
            isPSubset = isSubsetOf(CjIndices,CpIndices);
            % If the indices of p are a subset of those of j: find the
            if isPSubset
                newRow(1,end+1) = p;
            end
        end
        % append with zeros if necessary
        if size(PsubsetOfJIndices,2) < size(newRow,2)
            PsubsetOfJIndices = [PsubsetOfJIndices zeros(size(PsubsetOfJIndices,1),size(newRow,2)-size(PsubsetOfJIndices,2))];
        elseif size(PsubsetOfJIndices,2) > size(newRow,2)
            newRow = [newRow zeros(1,size(PsubsetOfJIndices,2)-size(newRow,2))];
        end
        PsubsetOfJIndices(j,:) = newRow;
    end
    numOfPsubsetsInJ = size(PsubsetOfJIndices,2);
    
end