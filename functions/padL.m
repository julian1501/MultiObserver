function paddedL = padL(L,outputsID,numOutputs)
% padL Function
%
% The 'padL' function creates a zero-padded version of an observer matrix ('L') 
% based on a set of specified output indices ('outputsID'). It ensures that 
% the resulting matrix has the desired dimensions for use in the SSMO, with
% zeros in positions corresponding to outputs not included in 'outputsID'.
%
% Documentation written by ChatGPT.
%
% Inputs:
% -------
% - 'L': The observer matrix to be padded. This matrix has dimensions 
%   corresponding to the number of original states and the number of outputs 
%   defined by the observer.
% - 'outputsID': A vector of indices specifying which outputs are present in 'L'.
% - 'numOutputs': The total number of outputs in the system. This determines 
%   the number of columns in the padded matrix.
%
% Outputs:
% --------
% - 'paddedL': The padded observer matrix. It has the same number of rows 
%   as the input matrix 'L' but includes additional columns filled with zeros 
%   for outputs not specified in 'outputsID'. The total number of columns 
%   equals 'numOutputs'.
%
% Function Description:
% ---------------------
% The function takes the observer matrix 'L' and pads it with zeros in the 
% columns corresponding to outputs not listed in 'outputsID'. It ensures that 
% the resulting matrix aligns with the system's total number of outputs.
% It is used to create an L matrix that can be multiplied with the full
% output instead of its corresponing subset of the outputs and still give
% the same result.
    
    numOriginalStates  = size(L,1);
    numObserverOutputs = size(L,2);
    paddedL = zeros(numOriginalStates,numOutputs);
    
    for i = 1:1:numObserverOutputs
        colId = outputsID(i);
        paddedL(:,colId) = L(:,i);
    end

end