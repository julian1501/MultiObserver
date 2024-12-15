function [Ai,Li] = defineObservers(A,CJ,eigenvalues,obj)
% defineObservers Function
%
% The 'defineObservers' function configures the observer matrices 'Ai' and 
% 'Li' for a set of systems defined by matrix 'A' and a set of output 
% matrices 'CJ'. It ensures that the systems are observable and stable by 
% placing eigenvalues for each observer's dynamics.
%
% This documentation was written by ChatGPT.
%
% Syntax:
% -------
% '[Ai, Li] = defineObservers(A, CJ, eigenvalues, obj)'
%
% Inputs:
% -------
% - 'A' (matrix): The system state matrix, shared among all observers.
% - 'CJ' (3D array): A collection of output matrices for the observers, 
%   where 'CJ(:,:,i)' corresponds to the 'i'th observer.
% - 'eigenvalues' (vector): Desired eigenvalues for the closed-loop 
%   dynamics of each observer.
% - 'obj' (object): Contains system properties, including:
%     - 'obj.nx': Number of states in the system.
%     - 'obj.numOutputsObservers': Number of outputs per observer.
%     - 'obj.numObservers': Total number of observers.
%
% Outputs:
% --------
% - 'Ai' (3D array): A collection of state matrices for the observers, 
%   where 'Ai(:,:,i)' corresponds to the 'i'th observer.
% - 'Li' (3D array): A collection of observer gain matrices, where 
%   'Li(:,:,i)' corresponds to the 'i'th observer.
%
% Behavior:
% ---------
% 1. Initializes 'Ai' and 'Li' as empty 3D arrays to hold matrices for all 
%    observers.
% 2. For each observer:
%    - Checks if the pair '(A, Cj)' is observable, where 'Cj = CJ(:,:,i)'.
%    - Uses the 'place' function to calculate the observer gain matrix 'L' 
%      such that the closed-loop eigenvalues of 'A + L*Cj' match the 
%      specified 'eigenvalues'.
%    - Ensures that 'A + L*Cj' is stable. If not, an error is raised.
%
% Example Scenarios:
% ------------------
% Inputs:
% - 'A = [0 1; -10 -1]'
% - 'CJ(:,:,1) = [1 0; 0 1; 1 0];
%    CJ(:,:,2) = [1 0; 0 1; 0 1];
%    CJ(:,:,3) = [1 0; 1 0; 0 1];
%    CJ(:,:,4) = [0 1; 1 0; 0 1];'
% - 'eigenvalues = [-2, -3]'
% - 'obj.numObservers = 4; obj.nx = 2; obj.numOutputsObservers = 2;'
%
% Outputs:
% - 'Ai' will be a stack of the input matrix 'A' for each observer.
% - 'Li' will contain the gain matrices computed for each '(A, Cj)' pair.
%
% Example Stability Check:
% -------------------------
% For each observer, the function checks the eigenvalues of 'A + L*Cj' to 
% confirm stability. If unstable, an error with diagnostic information is 
% raised.
%
% Dependencies:
% -------------
% - isObsv.m: Verifies if the pair '(A, Cj)' is observable.
% - place.m: Calculates the observer gain matrix 'L' to place eigenvalues.
% - isMatrixStable.m: Confirms the stability of 'A + L*Cj'.
%
% Notes:
% ------
% - All output matrices 'Cj' must result in an observable pair '(A, Cj)'. 
%   If not, the function raises an error.
% - The eigenvalues in 'eigenvalues' must be carefully chosen to ensure 
%   stability of the closed-loop dynamics.
% - Stability is checked iteratively for each observer, providing detailed 
%   diagnostics if a problem occurs.
%
% See also:
% ---------
% isObsv, place, isMatrixStable

    Ai = zeros(size(A,1),size(A,2),obj.numObservers);
    Li = zeros(size(place(A',CJ(:,:,1)',eigenvalues),2),size(place(A',CJ(:,:,1)',eigenvalues),1),obj.numObservers);

    % Loop through all rows of CJ and place the eigenvalues at
    % 'eigenvalues'.
    for l = 1:1:obj.numObservers
        % Select the observer for which to calculate the Aj + LjCj and Bi
        Cj = CJ(:,:,l);
        if ~isObsv(A,Cj)
            disp('A =')
            disp(A);
            disp('Cj =')
            disp(Cj)
            error('A pair (A,Cj) is not observable')
        end

        Ai(:,:,l) = A;
        L = -place(A',Cj',eigenvalues)';
        Li(:,:,l) = L;
        % Stability check
        if ~isMatrixStable(A+L*Cj)
            disp("The desired eigenvalues of A+LC")
            disp(eigenvalues)
            disp('The actual eigenvalues of A+LC:')
            disp(eig(A+L*Cj))
            error('The chosen Lj does not make Aj + LjCj stable')
        end
               
    end

end