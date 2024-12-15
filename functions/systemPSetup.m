function [Ap,Bp] = systemPSetup(mo,Lpadded)
% systemPSetup Function
%
% Constructs the 'Ap' and 'Bp' matrices for a multi-observer system, where 
% 'Ap' incorporates observer dynamics, and 'Bp' accounts for input and output corrections.
%
% Documentation written by ChatGPT.
%
% Syntax:
% -------
% '[Ap, Bp] = systemPSetup(mo, Lpadded)'
%
% Inputs:
% -------
% - 'mo': Multi-observer system object containing the following properties:
%   - 'nx': Number of states in the system.
%   - 'numObservers': Number of observers in the system.
%   - 'sys.E': Input-to-state matrix ('E') of the original system (optional).
%   - 'Ai': State-space 'A' matrices for each observer, organized in a 3D array.
%   - 'Li': Observer gain matrices ('L'), organized in a 3D array.
%   - 'Ci': Output matrices ('C'), organized in a 3D array.
% - 'Lpadded': A 3D array of gain matrices ('L') padded to include all output dimensions.
%
% Outputs:
% --------
% - 'Ap': A 3D array of modified state-space 'A' matrices, incorporating 
%   observer dynamics. Dimensions: '(nx x nx x numObservers)'.
% - 'Bp': A 3D array of input-to-state correction matrices. If the system 
%   has nonlinear dynamics ('sys.E'), 'Bp' combines the 'E' matrix with the 
%   padded gain matrix. Otherwise, it consists of the negative padded gain matrix.
%
% Implementation Steps:
% ---------------------
% 1. Initialize 'Ap' as a 3D array with dimensions '(nx x nx x numObservers)'.
% 2. Define 'Bp' based on whether the system includes a non-empty input-to-state 
%    matrix ('sys.E'):
%    - If 'sys.E' exists, concatenate 'E' with the negated 'Lpadded'.
%    - If 'sys.E' is empty, 'Bp' is set to '-Lpadded'.
% 3. Loop over the observers to compute each slice of 'Ap' using the formula:
%    'Ap(:,:,i) = Ai(:,:,i) + Li(:,:,i) * Ci(:,:,i)'.
%
% Matrix Structure:
% -----------------
% - 'Ap(:,:,i)' represents the modified state-space matrix for the 'i'th observer.
% - 'Bp(:,:,i)' includes contributions from the system's 'E' matrix (if available) 
%   and the negated observer gains.
%
% See also:
% ---------
% ctrb, ssmo, pad3DL

    
    Ap = zeros(mo.nx,mo.nx,mo.numObservers);
    if size(mo.sys.E,2) > 0
        Bp = cat(2,repmat(mo.sys.E,1,1,size(Lpadded,3)), -Lpadded);
    else
        Bp = -Lpadded;
    end

    for i = 1:1:mo.numObservers
        Ap(:,:,i) = mo.Ai(:,:,i) + mo.Li(:,:,i)*mo.Ci(:,:,i);
    end

end