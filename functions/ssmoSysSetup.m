function [A,B] = ssmoSysSetup(q,ssmo)
% ssmoSysSetup Function
%
% Constructs the state-space matrices 'A' and 'B' for a state-space 
% multi-observer (SSMO) system, based on the coefficients of a 
% characteristic polynomial and the SSMO object.
%
% Documentation written by ChatGPT.
%
% Syntax:
% -------
% '[A, B] = ssmoSysSetup(q, ssmo)'
%
% Inputs:
% -------
% - 'q': A column vector containing the coefficients of the characteristic 
%   polynomial (excluding the leading coefficient) of the system.
% - 'ssmo': An instance of the 'ssmo' class, which includes system 
%   dimensions and properties like 'numOutputs' and 'NLsize'.
%
% Outputs:
% --------
% - 'A': The state-space matrix 'A' for the overall SSMO system. 
% - 'B': The state-space matrix 'B' for the overall SSMO system.
%
% Implementation Steps:
% ---------------------
% 1. Compute the top row of the companion form matrix 'A' using the 
%    coefficients 'q'.
% 2. Construct the remaining rows of the companion form matrix by placing 
%    an identity matrix in the subdiagonal and padding with zeros.
% 3. Combine the top row and subdiagonal to form the full matrix 'Avalues'.
% 4. Extend 'Avalues' to account for all outputs and nonlinear states by 
%    taking the Kronecker product ('kron') with an identity matrix of size 
%    equal to the number of outputs and nonlinear states.
% 5. Construct the input matrix 'Bvalues' for the companion form, with a 1 
%    at the top and zeros elsewhere.
% 6. Extend 'Bvalues' to match the size of the output space using 
%    Kronecker product with the identity matrix.
%
% Example:
% --------
% % Define coefficients of the characteristic polynomial
% q = [2.5; -3.0; 1.5];
%
% % Create an ssmo object
% ssmoObj = <ssmo_object>;
%
% % Call ssmoSysSetup
% [A, B] = ssmoSysSetup(q, ssmoObj);
%
% Notes:
% ------
% - The SSMO object ('ssmo') must contain the following properties:
%   - 'sys.nx': Number of states in the system.
%   - 'numOutputs': Number of system outputs.
%   - 'sys.NLsize': Number of nonlinear components (if any).
% - The 'kron' function is used to expand the matrices to accommodate all 
%   outputs and nonlinear states.
%
% Matrix Structure:
% -----------------
% - 'A' is constructed by placing 'Avalues' for each observer in the 
%   Kronecker product, resulting in a block-diagonal structure with 
%   dimensions proportional to the number of outputs and nonlinear states.
% - 'B' is similarly extended to the output space using the Kronecker 
%   product.
%
% See also:
% ---------
% kron, ssmo, rootsToCoefficients

    topA = -1.*q;
    bottomA = [eye(ssmo.sys.nx-1) zeros(ssmo.sys.nx-1,1)];
    Avalues = [topA; bottomA];
    I = eye(ssmo.numOutputs + ssmo.sys.NLsize);
    A = kron(Avalues,I);

    Bvalues = [1; zeros(ssmo.sys.nx - 1,1)];
    B = kron(Bvalues,I);

end