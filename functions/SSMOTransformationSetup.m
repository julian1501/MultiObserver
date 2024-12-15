function T = SSMOTransformationSetup(Ap,Bp,q,mo)
% SSMOTransformationSetup Function
%
% Constructs the transformation matrices 'T' for a State-Space Multi-Observer 
% (SSMO) system.
%
% Documentation written by ChatGPT.
%
% Syntax:
% -------
% 'T = SSMOTransformationSetup(Ap, Bp, q, mo)'
%
% Inputs:
% -------
% - 'Ap': A 3D array of state-space 'A' matrices, where each slice along the 
%   third dimension corresponds to an observer's 'A' matrix.
% - 'Bp': A 3D array of state-space 'B' matrices, where each slice along the 
%   third dimension corresponds to an observer's 'B' matrix.
% - 'q': A vector of coefficients from the characteristic polynomial (excluding 
%   the leading coefficient).
% - 'mo': An object containing properties of the multi-observer system, including:
%   - 'nx': Number of states in the system.
%   - 'numOutputs': Number of system outputs.
%   - 'sys.NLsize': Number of nonlinear components (if any).
%   - 'numObservers': Total number of observers.
%
% Outputs:
% --------
% - 'T': A 3D array of transformation matrices, where each slice corresponds 
%   to a specific observer. Dimensions are 
%   '(nx x ((numOutputs + NLsize) * nx) x numObservers)'.
%
% Implementation Steps:
% ---------------------
% 1. Compute the controllability matrices ('Rp') for each observer using the 
%    'ctrb' function, which constructs the controllability matrix from 'Ap' 
%    and 'Bp' for each observer.
% 2. Generate 'RqValues', a companion-form-like matrix based on the coefficients 
%    'q', where each row shifts the coefficients.
% 3. Expand 'RqValues' to accommodate all outputs and nonlinear states by 
%    taking the Kronecker product ('kron') with an appropriately sized identity matrix.
% 4. Multiply the controllability matrix 'Rp' with the expanded 'Rq' matrix 
%    to create the transformation matrix 'T' for each observer.
%
% Example:
% --------
% % Define Ap and Bp as 3D arrays (A and B matrices for multiple observers)
% Ap = rand(3,3,5); % Example: 5 observers, 3x3 A matrices
% Bp = rand(3,1,5); % Example: 5 observers, 3x1 B matrices
%
% % Define the polynomial coefficients and observer object
% q = [2.5; -3.0; 1.5];
% mo.nx = 3;
% mo.numOutputs = 2;
% mo.sys.NLsize = 1;
% mo.numObservers = 5;
%
% % Call SSMOTransformationSetup
% T = SSMOTransformationSetup(Ap, Bp, q, mo);
%
% Notes:
% ------
% - The 'RqValues' matrix is constructed using the companion matrix structure 
%   derived from the coefficients 'q'.
% - The Kronecker product ('kron') ensures the transformation is scaled to 
%   include all outputs and nonlinear states.
%
% Matrix Structure:
% -----------------
% - 'Rp' is the controllability matrix for each observer.
% - 'Rq' is derived by expanding the companion-form coefficients of the 
%   characteristic polynomial.
% - Each transformation matrix 'T(:,:,i)' is the product of 'Rp(:,:,i)' and 'Rq'.
%
% See also:
% ---------
% ctrb, kron, ssmo, ssmoSysSetup

    
    % precompute dimensions
    a = mo.nx*(mo.numOutputs + mo.sys.NLsize);
    c = mo.nx;
    
    % Generate Rp matrices
    Rp = zeros(c,a,mo.numObservers);
    for i = 1:1:mo.numObservers
       Rp(:,:,i) = ctrb(Ap(:,:,i),Bp(:,:,i));
    end
    
    % Define correct I to use in kron product
    I = eye(mo.numOutputs + mo.sys.NLsize);
    RqValues = zeros(mo.nx);

    % Place single values of Rq correctly before expanding them with kron
    % prouct.
    for i = 1:1:mo.nx
        newRow = [zeros(1,i-1) 1 q(1:end-1)];
        RqValues(i,:) = newRow(1:mo.nx);
    end

    % multiply all individual eigenvalues by the appropriatly sized
    % identity matrix
    Rq = kron(RqValues,I);

    % Create all T matrices by multiplying Rp and Rq
    T = zeros(mo.nx,(mo.numOutputs + mo.sys.NLsize)*mo.nx,mo.numObservers);
    for i = 1:1:mo.numObservers
        T(:,:,i) = Rp(:,:,i)*Rq;
    end

end