function Lpadded = pad3DL(mo)
% pad3DL Function
%
% The 'pad3DL' function generates a 3D matrix of padded observer matrices ('L') 
% for a 3D-CMO system. Each observer's matrix is padded to match the 
% total system outputs, with each resulting padded matrix placed in the third 
% dimension of the output.
%
% Documentation written by ChatGPT.
%
% Inputs:
% -------
% - 'mo': An instance of the multi-observer ('mo') class. The class should 
%   contain the following relevant properties:
%   - 'nx': The number of states in the system.
%   - 'numOutputs': The total number of outputs in the system.
%   - 'numObservers': The total number of observers in the multi-observer.
%   - 'Li': A 3D array of observer matrices for each observer, where the 
%     third dimension corresponds to the observer index.
%   - 'CiIndices': A 2D matrix where each row contains the indices of the 
%     outputs used by the corresponding observer.
%
% Outputs:
% --------
% - 'Lpadded': A 3D matrix containing the padded 'L' matrices for all observers. 
%   Each 2D slice along the third dimension corresponds to the padded observer 
%   matrix for one observer.
%
% Function Description:
% ---------------------
% The function iterates through the observer matrices in the multi-observer 
% system and applies zero-padding to each matrix using the 'padL' function. 
% The padding ensures that each observer matrix aligns with the total number 
% of system outputs. The padded matrices are then stacked along the third 
% dimension to form the output 'Lpadded'.
%
% Initialization Steps:
% ---------------------
% - The function initializes 'Lpadded' as a zero matrix with dimensions:
%   - Rows: Number of system states ('nx').
%   - Columns: Total number of system outputs ('numOutputs').
%   - Third dimension: Number of observers ('numObservers').
% - It iterates over each observer:
%   - Extracts the observer's matrix ('L') from 'Li'.
%   - Extracts the corresponding output indices ('cIndices') from 'CiIndices'.
%   - Calls the 'padL' function to pad the observer's matrix to the total 
%     number of system outputs.
%   - Assigns the resulting padded matrix to the appropriate slice of 'Lpadded'.
%
% Notes:
% ------
% - The 'padL' function is used to handle the zero-padding for individual 
%   observer matrices.
% - The 'mo' object must include the required properties ('nx', 'numOutputs', 
%   'numObservers', 'Li', 'CiIndices') for the function to work correctly.
%
% See also:
% ---------
% padL, mo, cmo3d

    
    Lpadded = zeros(mo.nx,mo.numOutputs,mo.numObservers);

    for c = 1:1:mo.numObservers
        L = mo.Li(:,:,c);
        cIndices = mo.CiIndices(c,:);
        Lpadded(:,:,c) = padL(L,cIndices,mo.numOutputs);
    end

end