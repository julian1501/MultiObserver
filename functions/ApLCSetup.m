function [ApLCi,LCi] = ApLCSetup(mo)
% AmLCSetup Function
%
% Constructs the 'ApLCi' and 'LCi' matrices for each observer in the system,
% incorporating the observer gains ('Li') and output matrices ('Ci').
%
% Documentation written by ChatGPT.
%
% Syntax:
% -------
% '[ApLCi, LCi] = AmLCSetup(mo)'
%
% Inputs:
% -------
% - 'mo': Multi-observer system object containing the following properties:
%   - 'nx': Number of states in the system.
%   - 'numObservers': Number of observers in the system.
%   - 'Ai': State-space 'A' matrices for each observer, organized in a 3D array.
%   - 'Li': Observer gain matrices ('L'), organized in a 3D array.
%   - 'Ci': Output matrices ('C'), organized in a 3D array.
%
% Outputs:
% --------
% - 'ApLCi': A 3D array of modified 'A' matrices with observer gains included.
%   Each slice of 'ApLCi' represents the modified 'A' matrix for each observer.
%   Dimensions: '(nx x nx x numObservers)'.
% - 'LCi': A 3D array of matrices resulting from the multiplication of 
%   observer gains ('Li') and output matrices ('Ci'). Each slice of 'LCi'
%   represents this product for each observer. Dimensions: '(nx x nx x numObservers)'.
%
% Implementation Steps:
% ---------------------
% 1. Initialize 'LCi' as a 3D array of zeros, with dimensions '(nx x nx x numObservers)'.
% 2. Initialize 'ApLCi' as a 3D array of zeros, with dimensions '(nx x nx x numObservers)'.
% 3. Loop over each observer:
%    - Compute 'LCl = Li(:,:,l) * Ci(:,:,l)' for each observer.
%    - Modify 'ApLCi(:,:,l)' by adding 'LCl' to the 'Ai(:,:,l)' matrix.
%    - Store the result of 'LCl' in 'LCi(:,:,l)'.
%
% Notes:
% ------
% - The function computes two key matrices: 'ApLCi' and 'LCi' for each observer.
% - 'ApLCi' is the modified 'A' matrix for each observer, incorporating the 
%   contribution of the observer's gain and output matrices.
% - 'LCi' stores the contribution from the observer's gain and output matrices 
%   alone (without the state-space dynamics from 'Ai').
%
% Matrix Structure:
% -----------------
% - 'ApLCi(:,:,l)' is the modified state-space matrix for the 'l'th observer 
%   after incorporating the observer gain and output matrix.
% - 'LCi(:,:,l)' stores the product of the observer gain matrix 'Li' and the 
%   output matrix 'Ci' for the 'l'th observer.
%
% See also:
% ---------
% ssmo, systemPSetup, pad3DL

    
    % Define empty LC
    LCi = zeros(mo.nx,mo.nx,mo.numObservers);
    
    % Create empty matrix to store A's on the diagonal
    ApLCi =  zeros(mo.nx,mo.nx,mo.numObservers);

    % Add LjCj from Aj and place on the diagonal
    for l = 1:1:mo.numObservers
        LCl = mo.Li(:,:,l)*mo.Ci(:,:,l);
        ApLCi(:,:,l) = mo.Ai(:,:,l) + LCl;
        LCi(:,:,l) = LCl;
    end

end