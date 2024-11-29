classdef mo
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        % System that the multi-observer observes
        sys
        % Number of system states (size of A matrix)
        nx
        % Number of different possible outputs
        ny
        % Number of inputs
        nu
        % Number of outputs of the whole system (e.g. number of sensors)
        numOutputs
        % Number of J-observers
        numObservers
        % Number of outputs of each J-observer (often
        % numOuptus-numAttackedOutputs)
        numOutputsObservers
        % Outputs of each J-observer
        Ci
        % Indices of each J-observer
        CiIndices
        % 3D matrix that stores all the attack values for J observers
        attack3D
        % All A matrices for the J observer
        Ai
        % All L matrices for the J observer
        Li
    end

    methods
        function obj = mo(sys,attack,numOutputs)
            %UNTITLED6 Construct an instance of this class
            %   Detailed explanation goes here
            obj.sys = sys;
            obj.nx = size(sys.A,1);
            obj.ny = size(sys.C,1);
            obj.nu = size(sys.B,2);
            % Check whether numoutputs > 2*numAttackedOutputs
            if ~ (numOutputs > 2* attack.numAttacks)
               error('The number of outputs is not larger then twice the number of attacked outputs %3.0f <= %3.0f',numOutputs,numAttackedOutputs); 
            end
            obj.numOutputs = numOutputs;
            obj.numOutputsObservers = numOutputs - attack.numAttacks;
            obj.numObservers = nchoosek(numOutputs,attack.numAttacks);

            COutputs = CNSetup(obj);
            [Ci,CiIndices,attack3D] = CsetSetup(COutputs,attack,obj);

            obj.Ci = Ci;
            obj.CiIndices = CiIndices;
            obj.attack3D = attack3D;
            
            eigenvalueOptions = [-3 -4 -5 -6 -7 -8 -9 -10 -11 -12 -13 -14];
            eigenvalues = eigenvalueOptions(1:numOriginalStates);
        
            [Ai,Li] = defineObservers(sysA,Ci,eigenvalues,obj);

            obj.Ai = Ai;
            obj.Li = Li;

        end

        function COutputs = CNSetup(obj)
            % COutputs = CNSetup(sys,numOutputs) sets up the CN matrix that
            % contains all the outputs of the CMOsystem. The rows of sys.C are
            % treated as the possible outputs: if there are less then numOutputs
            % rows in sys.C duplicates are used until COutputs has numOutputs rows.
            % If there are more rows in sys.C then numOutputs the bottom rows are
            % not used.
            %
            % For example:
            %   - sys.C = [1 0; 0 1] & numOutputs = 2
            %       -> COutputs = [1 0; 0 1]
            %   - sys.C = [1 0; 0 1] & numOutputs = 3
            %       -> COutputs = [1 0; 0 1; 1 0]
            %   - sys.C = [1 0; 0 1] & numOutputs = 1
            %       -> COutputs = [1 0]
            
            % Extract the number of possible ouputs
            COptions = obj.sys.C;
            numOptions = size(COptions,1);
            
            % If the number of actual outputs (numOuputs) is smaller then the
            % number of possible outputs: take the first numOuputs rows of Coptions.
            % If the number of actual outputs (numOutputs) is larger then the
            % number of possible outputs: duplicate Coptions until there are enough
            % it has a length longer then numOutputs and trim off the bottom rows
            % untill it matches numOutputs.
            copiesRequired = ceil(obj.numOutputs/numOptions);
            % Create empty matrix to store all duplicates of the options
            COutputOptions = repmat(COptions,copiesRequired,1);
            COutputs = COutputOptions(1:obj.numOutputs,:);
        
        end

        function [Cset,CsetIndices,setAttack] = CsetSetup(CN,attack,obj)
            % [Cset, CsetIndices] =
            % CsetSetup(CN,sizeObserver,numOutputs,numObservers) sets up a 3D array
            % with all observers with outputs a subset of CN. The cardinality of
            % this subset is sizeObserver and numObservers indicates the amount of
            % subsets that are made. CsetIndices is a matrix where each row stored
            % the indices of the observers that make up a subset.
            %
            % For example:
            %   - CN = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1] 
            %     attack = [1 0 1 0];
            %     numObservers = 4 & numOutputsObserver = 3
            %       -> Cset(:,:,1) = [1 0 0 0;
            %                         0 1 0 0;
            %                         0 0 1 0];
            %          Cset(:,:,2) = [1 0 0 0;
            %                         0 1 0 0;
            %                         0 0 0 1];
            %          Cset(:,:,3) = [1 0 0 0;
            %                         0 0 1 0;
            %                         0 0 0 1];
            %          Cset(:,:,4) = [0 1 0 0;
            %                         0 0 1 0;
            %                         0 0 0 1];
            %       -> CsetIndices = [1 2 3; 1 2 4; 1 3 4; 2 3 4];
            %       -> setAttack(:,:,1) = [1; 0; 1];
            %          setAttack(:,:,2) = [1; 0; 0];
            %          setAttack(:,:,1) = [1; 1; 0];
            %          setAttack(:,:,1) = [0; 1; 0];
        
            % Define a list with all indices, so 1,2,...,N
            outputList = 1:1:obj.numOutputs;
            
            % Select the indices of the combinations of Cj's
            CsetIndices = nchoosek(outputList,numOutputsObserver);
            
            % Loop over the combinations and add them to the empty CJ
            Cset = zeros(numOutputsObserver,obj.nx,obj.numObservers);
            setAttack = zeros(numOutputsObserver,1,obj.numObservers);
            for j = 1:1:obj.numObservers
                % In every j of CJ
                Cselection = CsetIndices(j,:);
                for k = 1:1:obj.numOutputsObserver
                    % in every row k of a Cj
                    % Select first row of Cj
                    CNId = Cselection(k);
                    Cset(k,:,j) = CN(CNId,:);
                    setAttack(k,:,j) = attack.attackList(CNId,:);
                end
        
            end
        
        end

        function [Ai,Li] = defineObservers(A,CO,eigenvalues,obj)
            % add shit here
        
            % Define the empty matrix (n*J*N x n*J*N) AJ. Where N is the number of outputs.
            Ai = zeros(obj.nx,obj.nx,obj.numObservers);
        
            % Define the empty matrix (n x N*J) LJ. 
            Li = zeros(obj.nx,obj.numOutputsObserver,obj.numObservers);
        
            % Loop through all rows of CJ and place the eigenvalues at
            % 'eigenvalues'.
            for l = 1:1:obj.numObservers

                % Select the observer for which to calculate the Aj + LjCj and Bi
                Cj = CO(:,:,l);
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


    end

end