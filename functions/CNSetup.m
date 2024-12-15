function COutputs = CNSetup(obj)
% CNSetup Function
%
% The 'CNSetup' function generates a matrix 'COutputs' containing the 
% outputs of the Multi-Observer (MO) system. The rows of the system's 'C' 
% matrix ('sys.C') are treated as possible output options and are either 
% repeated or truncated to ensure that the resulting matrix has exactly 
% 'numOutputs' rows.
%
% This documentation was written by ChatGPT.
%
% Syntax:
% -------
% 'COutputs = CNSetup(obj)'
%
% Inputs:
% -------
% - 'obj' (cmo3d object): 
%   The 'cmo3d' object containing the system ('obj.sys') and the desired 
%   number of outputs ('obj.numOutputs').
%
% Outputs:
% --------
% - 'COutputs' (matrix): 
%   A matrix with 'numOutputs' rows, constructed by repeating or truncating
%   the rows of 'sys.C'.
%
% Behavior:
% ---------
% The function constructs 'COutputs' based on the following rules:
% 1. If 'numOutputs' is less than or equal to the number of rows in 'sys.C',
%    only the first 'numOutputs' rows are used.
% 2. If 'numOutputs' exceeds the number of rows in 'sys.C', the rows of 
%    'sys.C' are repeated until there are at least 'numOutputs' rows, and 
%    any excess rows are truncated to match 'numOutputs'.
%
% Example Scenarios:
% ------------------
% - Case 1: 'sys.C' has enough rows to satisfy 'numOutputs':
%   sys.C = [1 0; 0 1]; 
%   obj.numOutputs = 2;
%   COutputs = CNSetup(obj);
%   % Result:
%   % COutputs = 
%   %     [1 0;
%   %      0 1]
% - Case 2: 'sys.C' has fewer rows than 'numOutputs':
%   sys.C = [1 0; 0 1];
%   obj.numOutputs = 3;
%   COutputs = CNSetup(obj);
%   % Result:
%   % COutputs =
%   %     [1 0;
%   %      0 1;
%   %      1 0]
% - Case 3: 'sys.C' has more rows than 'numOutputs':
%   sys.C = [1 0; 0 1; -1 0]; 
%   obj.numOutputs = 2;
%   COutputs = CNSetup(obj);
%   % Result:
%   % COutputs =
%   %     [1 0;
%   %      0 1]
%
% Internal Logic:
% ----------------
% 1. Extracts 'sys.C' as the base matrix of possible output rows.
% 2. Computes the number of copies of 'sys.C' needed to meet or exceed 
%    'numOutputs' rows.
% 3. Creates a repeated matrix by duplicating 'sys.C' as many times as needed.
% 4. Truncates the resulting matrix to exactly 'numOutputs' rows.
%
% Notes:
% ------
% - This function assumes that the 'sys.C' matrix is defined in the 'sys' 
%   property of the 'obj' object.
% - The function dynamically adapts the output matrix to any 'numOutputs' 
%   value, ensuring compatibility with varying system requirements.
%
% Dependencies:
% -------------
% - The 'obj' must be an instance of a class (e.g., 'mo') with the 
%   properties 'sys.C' and 'numOutputs'.

    % Extract the number of possible ouputs
    COptions = obj.sys.C;
    numOptions = size(COptions,1);
    
    % If the number of actual outputs (numOuputs) is smaller then the
    % number of possible outputs: take the first numOuputs rows of Coptions.
    % If the number of actual outputs (numOutputs) is larger then the
    % number of possible outputs: duplicate Coptions until there are enough
    % it has a length longer then numOutputs and trim off the bottom rows
    % untill it matches numOutputs.

    copiesRequired = ceil(obj.numOutputs/numOptions);
    % Create empty matrix to store all duplicates of the options
    COutputOptions = repmat(COptions,copiesRequired,1);
    COutputs = COutputOptions(1:obj.numOutputs,:);

end