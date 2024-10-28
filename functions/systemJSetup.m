function [AbarJ,BbarJ,CbarJ,DbarJ,LbarJ] = systemJSetup(A,B,CJ,D,numObserver,sizeObserver,eigenvalueOptions)
    % This function sets up the output injection gain matrices LJ
    % for the corresponding matrices CJ, that places the eigenvalues of
    % A+LjCj at 'eigenvalues'.

    numStates = size(A,1);
    numInputs = size(B,2);
    
    % Define the empty matrix (n*J*N x n*J*N) AJ. Where N is the number of outputs.
    AbarJ = zeros(numStates*sizeObserver*numObserver,numStates*sizeObserver*numObserver);
    % Define the empty matrix (n*J*N x k) BJ.
    BbarJ = zeros(numStates*sizeObserver*numObserver,numInputs);
    % Define the empty matrix (J x n*J*N)
    CbarJ = zeros(sizeObserver,numStates*sizeObserver*numObserver);
    % Define the empty matrix (n x N*J) LJ. 
    LbarJ = zeros(numStates*sizeObserver*numObserver,sizeObserver);

    % Determine the number of options for the eigenvalues
    options = size(eigenvalueOptions,2);
    if numStates > options
        error('There are more states then possible eigenvalues to choose from')
    end

    % Loop through all rows of CJ and place the eigenvalues at
    % 'eigenvalues'.
    for l = 1:1:numObserver
        % Select n eigenvalues out of eigenvalueOptions if the number of
        % options is larger then n. If the number of options is smaller
        % then n, throw an error.
        if options > numStates
            eigenvalues = selectRandomSubset(eigenvalueOptions,numStates);
        end
        % Select the observer for which to calculate the Aj + LjCj and Bi
        Cj = CJ(l:l+sizeObserver-1,:);
        % Calculate the MIMO OCF for the specific observer
        [~,Abar,Bbar,Cbar,~] = MIMOtoOCF(ss(A,B,Cj,0));
        % Append the new matrices to the big ones
        AbarJ((l-1)*sizeObserver*numStates+1:l*sizeObserver*numStates , (l-1)*sizeObserver*numStates+1:l*sizeObserver*numStates) = Abar;
        BbarJ((l-1)*sizeObserver*numStates+1:l*sizeObserver*numStates , 1:numInputs) = Bbar;
        CbarJ(:, (l-1)*sizeObserver*numStates+1:l*sizeObserver*numStates) = Cbar;
        DbarJ = 0;
        
        Lbar = chooseL(Abar,Cbar,eigenvalues,numStates);
        LbarJ((l-1)*(numStates*sizeObserver)+1:(l-1)*(numStates*sizeObserver) + numStates*sizeObserver, :) = Lbar;
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