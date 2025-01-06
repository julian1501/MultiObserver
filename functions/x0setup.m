function [x0, xIds] = x0setup(x0input,whichMO,sys,Jmo,Pmo)
% x0setup Function
%
% This function sets up the initial state vector 'x0' based on the input 
% 'x0input'and the specified structure of the system, considering the 
% number of observers and the configuration of the system (such as 2D-CMO, 
% 3D-CMO, and SSMO).
%
% Syntax:
% -------
% 'x0 = x0setup(x0input, whichMO, sys, Jmo, Pmo)'
%
% Inputs:
% -------
% - 'x0input': The initial input state vector for the system, where the 
%   first 
%   'sys.nx' are selected. This avoids errors when the list is longer.
% - 'whichMO': A vector specifying which modes of operation are active. 
%   It is a 3-element vector where:
%     - 'whichMO(1)' indicates if 2D CMO is active ('1' for active, '0' 
%       for inactive).
%     - 'whichMO(2)' indicates if 3D CMO is active.
%     - 'whichMO(3)' indicates if SSMO is active.
% - 'sys': A structure representing the system, containing the number of 
%   states ('nx') and the size of the nonlinearity ('NLsize').
% - 'Jmo': A structure representing the J-mode observers, including the 
%   number of observers ('numObservers') and other parameters.
% - 'Pmo': A structure representing the P-mode observers, also including 
%   'numObservers' and other parameters.
%
% Outputs:
% --------
% - 'x0': The initial state vector ('x0') as a column vector that includes 
%   all the states for the system and the observers, based on the mode 
%   configurations specified.
%
% Process:
% --------
% 1. Extract the system's state vector ('x0sys') from the first 'sys.nx' 
%    elements of 'x0input'.
% 2. Compute the total number of observers as the sum of 'Jmo.numObservers'
%    and 'Pmo.numObservers'.
% 3. Set up 'x0cmo2d' if the 2D CMO mode is active (if 'whichMO(1)' equals '1').
%    - It is initialized as a zero vector of size '(numObservers * sys.nx)'.
% 4. Set up 'x0cmo3d' if the 3D CMO mode is active (if 'whichMO(2)' equals '1').
%    - It is initialized as a zero 3D array of size '(sys.nx, 1, numObservers, 1)'.
% 5. Set up 'x0ssmo' if the SSMO mode is active (if 'whichMO(3)' equals '1').
%    - It is initialized as a zero vector of size '(sys.nx * (Jmo.numOutputs + sys.NLsize))'.
% 6. Concatenate the initialized vectors and arrays ('x0sys', 'x0cmo2d', 'x0cmo3d', and 'x0ssmo') 
%    to form the final initial state vector 'x0'.
%
%
% Matrix Structure:
% -----------------
% - 'x0sys': The first 'sys.nx' elements of 'x0input', representing the system's 
%   state vector.
% - 'x0cmo2d': The state vector for 2D CMO observers (if active), all zeros.
% - 'x0cmo3d': The state array for 3D CMO observers (if active), all zeros.
% - 'x0ssmo': The state vector for the SSMO (if active), all zeros.
%
% See also:
% ---------
% multiObserverODE


    x0sys = x0input(1:sys.nx);
%     xIds = struct([]);
    numObservers = Jmo.numObservers + Pmo.numObservers;
    if whichMO(1) == 1
        x0cmo2d = zeros(numObservers*sys.nx,1);
        xIds.xcmo2dStart = sys.nx + 1;
        xIds.xcmo2dEnd   = sys.nx + numObservers*sys.nx;
    else
        x0cmo2d = [];
        xIds.xcmo2dEnd = sys.nx;
    end

    if whichMO(2) == 1
        x0cmo3d = zeros(sys.nx,1,numObservers,1);
        xIds.xcmo3dStart = xIds.xcmo2dEnd + 1;
        xIds.xcmo3dEnd   = xIds.xcmo2dEnd + numObservers*sys.nx;
    else
        x0cmo3d = [];
        xIds.xcmo3dEnd = xIds.xcmo2dEnd;
    end

    if whichMO(3) == 1
        x0ssmo = zeros(sys.nx*(Jmo.numOutputs + sys.NLsize),1);
        xIds.xssmoStart = xIds.xcmo3dEnd + 1;
        xIds.xssmoEnd    = xIds.xcmo3dEnd + (sys.NLsize + Jmo.numOutputs)*sys.nx;
    else
        x0ssmo = [];
        xIds.xssmoStart = xIds.xcmo3dEnd;
    end
    
    x0 = [x0sys(:); x0cmo2d(:); x0cmo3d(:); x0ssmo(:)];
end