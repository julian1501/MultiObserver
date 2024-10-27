function LJ = LJSetup(system,CJ,N,eigenvalueOptions)
    % This function sets up the output injection gain matrices LJ
    % for the corresponding matrices CJ, that places the eigenvalues of
    % A+LjCj at 'eigenvalues'. Currently only works for CJ with only SISO
    % observers.
    
    % Extract A from system
    A = system.A;
    n = size(A,1);
    % Define the empty matrix (n x N) LJ. Where N is the number of outputs.
    LJ = zeros(n,N);

    % Determine the number of options for the eigenvalues
    options = size(eigenvalueOptions,2);
    

    % Loop through all rows of CJ and place the eigenvalues at
    % 'eigenvalues'.
    for l = 1:1:N
        % Select n eigenvalues out of eigenvalueOptions if the number of
        % options is larger then n
        if options > n
            eigenvalues = selectRandomSubset(eigenvalueOptions,n);
        end
        LJ(:,l) = chooseL(A,CJ(l,:),eigenvalues);
    end
    
end