function [ATildeJ,BTildeJ,CTildeJ,DTildeJ,LJ] = systemJSetup(A,B,CJ,D,eigenvalueOptions,setString,CMOdict)
    % This function sets up the output injection gain matrices LJ
    % for the corresponding matrices CJ, that places the eigenvalues of
    % A+LjCj at 'eigenvalues'.

    numOriginalStates = CMOdict('numOriginalStates');
    numOriginalInputs = CMOdict('numOriginalInputs');
    numOriginalOutputs = CMOdict('numOriginalOutputs');
    [numObservers, numOutputsObserver] = selectObserverSpecs(setString,CMOdict);

    % Define the empty matrix (n*J*N x n*J*N) AJ. Where N is the number of outputs.
    ATildeJ = zeros(numOriginalStates*numObservers,numOriginalStates*numObservers);
    % Define the empty matrix (n*J*N x k) BJ.
    BTildeJ = zeros(numOriginalStates*numObservers,numOriginalInputs);
    % Define the empty matrix (J x n*N)
    CTildeJ = zeros(numOutputsObserver,numOriginalStates*numObservers);

    % Define the empty matrix (n x N*J) LJ. 
    LJ = zeros(numOriginalStates*numObservers,numOutputsObserver);

    % Determine the number of options for the eigenvalues
    options = size(eigenvalueOptions,2);
    if numOriginalStates > options
        error('There are more states then possible eigenvalues to choose from')
    end

    % Loop through all rows of CJ and place the eigenvalues at
    % 'eigenvalues'.
    for l = 1:1:numObservers
        % Select n eigenvalues out of eigenvalueOptions if the number of
        % options is larger then n. If the number of options is smaller
        % then n, throw an error.
        if options > numOriginalStates
            eigenvalues = selectRandomSubset(eigenvalueOptions,numOriginalStates);
        end
        % Select the observer for which to calculate the Aj + LjCj and Bi
        Cj = CJ(:,(l-1)*numOriginalStates+1:l*numOriginalStates);
        ATildeJ((l-1)*numOriginalStates+1:l*numOriginalStates , (l-1)*numOriginalStates+1:l*numOriginalStates) = A;
        BTildeJ((l-1)*numOriginalStates+1:l*numOriginalStates , 1:numOriginalInputs) = B;
        CTildeJ(:,(l-1)*numOriginalStates+1:l*numOriginalStates) = Cj;
        DTildeJ = 0;
        L = -place(A',Cj',eigenvalues)';
        LJ((l-1)*(numOriginalStates)+1:(l-1)*(numOriginalStates) + numOriginalStates,:) = L;
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