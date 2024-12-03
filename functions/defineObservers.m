function [Ai,Li] = defineObservers(A,CJ,eigenvalues,obj)
    % [ATildeJ,BTildeJ,CTildeJ,DTildeJ,LJ] = 
    % systemJSetup(A,CJ,eigenvalueOptions,setString,CMOdict) sets up
    % large matrices that contain each system (ATildeJ, BTildeJ, CTildeJ,
    % DTildeJ, LJ) out of the setString (P or J) subset. The L for each
    % pair (Aj,Cj) is chosen based of eigenvalueOptions, if there are more
    % eigenvalue options then states: a random subset is chosen. To prevent
    % this random behaviour the list supplied should contain the same
    % number of options as states.
    % 
    % For example:
    %   - A  = [0 1; -10 -1]
    %     CJ = [1 0   1 0   1 0   0 1;
    %           0 1   0 1   1 0   1 0;
    %           1 0   0 1   0 1   0 1]
    %       -> ATildeJ = [A 0 0 0;
    %                     0 A 0 0;
    %                     0 0 A 0;
    %                     0 0 0 A]
    %       -> LJ = Examplary due to random behaviour!
    %               [-2     -1     -2   ;
    %                12.5   -0.5   12.5 ;
    %                -6     -0.5   -0.5 ;
    %                25     -2.75  -2.75;
    %                -1     -1     -1   ;
    %                12.5   12.5   -0.5 ;
    %                -0.5   -4     -0.5 ;
    %                -1.75  25     -1.75]

    % Define the empty matrix (n*J*N x n*J*N) AJ. Where N is the number of outputs.
    Ai = zeros(obj.nx,obj.nx,obj.numObservers);

    % Define the empty matrix (n x N*J) LJ. 
    Li = zeros(obj.nx,obj.numOutputsObservers,obj.numObservers);


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
            warning('A pair (A,Cj) is not observable')
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