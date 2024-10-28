function [AbarJ,BbarJ,CbarJ,DbarJ,LbarJ] = systemJSetup(A,B,CJ,D,numObserver,J,eigenvalueOptions)
    % This function sets up the output injection gain matrices LJ
    % for the corresponding matrices CJ, that places the eigenvalues of
    % A+LjCj at 'eigenvalues'. Currently only works for CJ with only SISO
    % observers.

    n = size(A,1);
    k = size(B,2);
    
    % Define the empty matrix (n*J*N x n*J*N) AJ. Where N is the number of outputs.
    AbarJ = zeros(n*J*numObserver,n*J*numObserver);
    % Define the empty matrix (n*J*N x k) BJ.
    BbarJ = zeros(n*J*numObserver,k);
    % Define the empty matrix (J x n*J*N)
    CbarJ = zeros(J,n*J*numObserver);
    % Define the empty matrix (n x N*J) LJ. 
    LbarJ = zeros(n*J*numObserver,J);

    % Determine the number of options for the eigenvalues
    options = size(eigenvalueOptions,2);

    % Loop through all rows of CJ and place the eigenvalues at
    % 'eigenvalues'.
    for l = 1:1:numObserver
        % Select n eigenvalues out of eigenvalueOptions if the number of
        % options is larger then n
        if options > n
            eigenvalues = selectRandomSubset(eigenvalueOptions,n);
        end
        % Select the observer for which to calculate the Aj + LjCj and Bi
        Cj = CJ(l:l+J-1,:);
        % Calculate the MIMO OCF for the specific observer
        [~,Abar,Bbar,Cbar,~] = MIMOtoOCF(ss(A,B,Cj,0));
        % Append the new matrices to the big ones
        AbarJ((l-1)*J*n+1:l*J*n , (l-1)*J*n+1:l*J*n) = Abar;
        BbarJ((l-1)*J*n+1:l*J*n , 1:k) = Bbar;
        CbarJ(:, (l-1)*J*n+1:l*J*n) = Cbar;
        DbarJ = 0;
        
        Lbar = chooseL(Abar,Cbar,eigenvalues,n);
        LbarJ((l-1)*(n*J)+1:(l-1)*(n*J) + n*J, :) = Lbar;
        % Stability check
        if ~isMatrixStable(Abar+Lbar*Cbar)
            disp("The desired eigenvalues of A+LC")
            disp(eigenvalues)
            disp('The actual eigenvalues of A+LC:')
            disp(eig(Abar+Lbar*Cbar))
            error('The chosen Lj does not make Aj + LjCj stable')
        end
       
    end

    
end