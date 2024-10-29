function [CMOsystem,Acmo,Bcmo,Ccmo,Dcmo,CJIndices] = subSetCMOSetup(inputSystem,sizeObserver,numOutputs)
    % This function sets up a conventional multi-observer (CMO) for the
    % inputSystem. Each observer in the bank of observers has
    % 'observerSize' outputs.
    % Required conditions:
    %   - The rows of inputSystem.C are all valid configurationf of the
    %     output, if the number of rows in inputSystem.C is larger then the
    %     number of outputs the first rows will be taken.
    
    % Extract needed matrices out system
    AInput = inputSystem.A;
    numOriginalStates = size(AInput,1);
    BInput = inputSystem.B;
    CInput = inputSystem.C;
    DInput = inputSystem.D;
    sizeCInput = size(CInput);

    

    % Check if system is stable, issue warning if system is unstable
    if isMatrixStable(AInput)
        fprintf('The system is internally stable. \n')
    else
        warning('The system is internally unstable. \n')
    end

    % Rewrite the system in observable canonical form pad with 0 outputs C
    % to have the same number of outputs as the observers in order to
    % create a proper matrix structure later. Cut off excess values in case
    % CInput > sizeObserver.


    paddedC = zeros(sizeObserver,numOriginalStates);
    paddedD = zeros(sizeObserver,size(BInput,2));
    paddedC(1:sizeCInput(1),1:sizeCInput(2)) = CInput;
    paddedD(1:sizeCInput(1),1:size(BInput,2)) = DInput;
    % Cut C and D to the correct size: sizeObserver
    paddedC = paddedC(1:sizeObserver,:);
    paddedD = paddedD(1:sizeObserver,:);
    inputSystemOCF = MIMOtoOCF(ss(inputSystem.A,inputSystem.B,paddedC,paddedD));
    AInputBar = inputSystemOCF.A;
    BInputBar = inputSystemOCF.B;
    CInputBar = inputSystemOCF.C;
    DInputBar = inputSystemOCF.D;

    disp('Abar: the basic system in OCF')
    disp(AInputBar)
    disp('Bbar: the basic system in OCF')
    disp(BInputBar)
    disp('Cbar: the basic system in OCF')
    disp(CInputBar)


    % Calculate the number of observers that will be used: all combinations
    % observerSize out all N outputs
    numObservers = nchoosek(numOutputs,sizeObserver);

    % CN is the C matrix with all N system outputs that will be combined into sets
    % of J outputs later on.
    CN = CNSetup(inputSystem,numOutputs);
    % CJ is the C matrix with all observerSize sized sets J that form an observer, so
    % every observerSize rows of CJ is a single observer
    fprintf('Finding indices for observers. \n')
    [CJ,CJIndices] = CJSetup(CN,sizeObserver,numOutputs,numObservers);

    % Define a set of eigenvalues from which n (the number of original 
    % states) are randomly chosen to be the eigenvalues of a single entry
    % of Aj + LjCj.
    eigenvalues = [-1 -2 -3 -4 -5 -6 -7 -8];
    % Set up the A,B,C and L matrices for each observer in the bank of
    % observers sized numObservers.
    fprintf('Defining output injection matrices for each observer in the bank. \n')
    [AJ,BJ,CJ,~,LJ] = systemJSetup(AInput, ...
                                   BInput, ...
                                   CJ, ...
                                   DInputBar, ...
                                   numObservers, ...
                                   sizeObserver, ...
                                   eigenvalues);
    
    % Rewrite all numObservers (n) observers and the original system
    % (transformed into OCF) into a single system as
    % Astar =
    % [   A      0    ...    0    ]
    % [ -L1C1 A1+L1C1 ...    0    ]
    % [    |     |     \     |    ]
    % [ -LnCn    0    ... An+LnCn ]
    % 
    % Bstar =
    % [ B  ]
    % [ B1 ]
    % [ |  ]
    % [ Bn ]
    % Cstar is a combination of the identity matrices corresponding to the
    % MIMO OCF form on the diagonal. Then all the rows which only contain 
    % zeros are removed For a system with 1 observer and 2 outputs for 
    % example:
    % Cstar =
    % [1 0 0 0 0 0 0 0]
    % [0 1 0 0 0 0 0 0]
    % [0 0 0 0 1 0 0 0]
    % [0 0 0 0 0 1 0 0]
    
    fprintf('Combining all observers into a single state-space system. \n')
    [Astar, Bstar,Cstar] = systemStarSetup(AInputBar, ...
                                           BInputBar, ...
                                           AJ, ...
                                           BJ, ...
                                           LJ, ...
                                           CJ, ...
                                           sizeObserver, ...
                                           numObservers, ...
                                           numOriginalStates);
    
    % We now define E: the matrix that combines the input and nosie as
    % E =
    % [B   0  ...  0  I ]
    % [B1 -L1 ...  0  0 ]
    % [ |  |   \   |  | ]
    % [Bn  0  ... -Ln 0 ]
    E = ESetup(Bstar,LJ,numObservers,sizeObserver,numOriginalStates);

    % We now create the state space system
    CMOsystem = ss(Astar,E,Cstar,0);
    Acmo = CMOsystem.A;
    Bcmo = CMOsystem.B;
    Ccmo = CMOsystem.C;
    Dcmo = CMOsystem.D;

end