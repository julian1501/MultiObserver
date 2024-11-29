function score = compareMO(dialog)
    fprintf(['\n' repmat('-',1,100) '\n'])
    inputs = inputDiaglog(dialog);
    
    sysNum = str2num(inputs{1});
    numOutputs = str2num(inputs{2});
    if lower(inputs{3}) == 'max'
        numAttackedOutputs = floor((numOutputs-1)/2);
    else
        numAttackedOutputs = str2num(inputs{3});
    end
    if lower(inputs{4}) == 'max'
        numOutputsPObservers = numOutputs-2*numAttackedOutputs;
    else
        numOutputsPObservers = str2num(inputs{4});
    end
    eigenvalueOptions = str2num(inputs{5});
    tspan = str2num(inputs{6});
    x0Options = str2num(inputs{7})';
    
    %% Calculations
    fprintf('The number of outputs is %3.0f: \n',numOutputs)
    
    % M: maximum number of corrupted outputs
    fprintf('The maximum allowable number of compromised outputs %3.0f: \n',numAttackedOutputs)
    numOutputsJObservers = numOutputs-numAttackedOutputs;
    fprintf('The size of each J observer is: %3.0f \n',numOutputsJObservers)
    fprintf('The size of each P observer is: %3.0f \n',numOutputsPObservers)
    numJObservers = nchoosek(numOutputs,numOutputsJObservers);
    fprintf('The number of J observers is: %3.0f \n',numJObservers)
    numPObservers = nchoosek(numOutputs,numOutputsPObservers);
    fprintf('The number of P observers is: %3.0f \n',numPObservers)
    
    % Noiseless system definition
    [sys,sysName] = xDampedSpringMassSetup(sysNum,repmat(0.3,1,20),repmat(5,1,20),repmat(0.6,1,20));
    
    sysA = sys.A;
    numOriginalStates  = size(sysA,1);
    sysB = sys.B;
    numOriginalInputs  = size(sysB,2);
    sysC = sys.C;
    numOriginalOutputs = size(sysC,1);
    sysD = sys.D;
    if ~isMatrixStable(sysA)
        warning('The system is unstable',sysName)
    end
    if sysD ~= 0
        error('Implementation for systems with D still needs work.')
    end
    
    
    % define a dictionary that stores all info
    MOstruct.numOutputs              = numOutputs;
    MOstruct.numAttackedOutputs      = numAttackedOutputs;
    MOstruct.numOutputsJObservers    = numOutputsJObservers;
    MOstruct.numJObservers           = numJObservers;
    MOstruct.numOutputsPObservers    = numOutputsPObservers;
    MOstruct.numPObservers           = numPObservers;
    MOstruct.numOriginalStates       = numOriginalStates;
    MOstruct.numOriginalInputs       = numOriginalInputs;
    MOstruct.numOriginalOutputs      = numOriginalOutputs;
    MOstruct.numSystems = numJObservers+numPObservers+1;
    
    % Define system input
    u = zeros(MOstruct.numOriginalInputs,1);
    
    
    % Setup outputs and noise 
    COutputs = CNSetup(sys,numOutputs);
    attack = attackSetup(MOstruct);
    [CJ,CJIndices,JAttack] = CsetSetup(COutputs,attack,'J',MOstruct);
    [CP,CPIndices,PAttack] = CsetSetup(COutputs,attack,'P',MOstruct);
    
    % find which p observers are subsets of each j observer
    [numOfPsubsetsInJ, PsubsetOfJIndices] = findIndices(CJIndices,CPIndices,MOstruct);
    MOstruct.numOfPsubsetsInJ = numOfPsubsetsInJ;
    
    eigenvalues = eigenvalueOptions(1:numOriginalStates);

    [AJ,LJ] = systemJSetup(sysA,CJ,eigenvalues,'J',MOstruct);
    [AP,LP] = systemJSetup(sysA,CP,eigenvalues,'P',MOstruct);

    if true      
        % Pad the L matrices so that they are compatible with the full output
        LJTilde = pad3DL(LJ,CJIndices,'J',MOstruct);
        LPTilde = pad3DL(LP,CPIndices,'P',MOstruct);
        
        % Define Ap and Bp for each observer
        [AJp,BJp] = systemPSetup(AJ,CJ,LJ,LJTilde,'J',MOstruct);
        [APp,BPp] = systemPSetup(AP,CP,LP,LPTilde,'P',MOstruct);
        
        % Derive the transfomration matrix for each observer
        q = rootsToCoefficients(eigenvalues);
        q = q(2:end);
        [TJ] = SSMOTransformationSetup(AJp,BJp,q,'J',MOstruct);
        [TP] = SSMOTransformationSetup(APp,BPp,q,'P',MOstruct);
        T = cat(3,zeros(size(TJ(:,:,1))),TJ,TP);
        
        % Define THE A and B matrices
        [THE_A,THE_B] = THEsystemSetup(q,MOstruct);
    end

    if true
        [ApLCJ,LCJ] = systemStarSetup3D(AJ,LJ,CJ,'J',MOstruct);
        [ApLCP,LCP] = systemStarSetup3D(AP,LP,CP,'P',MOstruct);
        
        % Pad the right side of LP with zeros to match the cross sectional size of
        % LJ
        padding = zeros(numOriginalStates,numOutputsJObservers-numOutputsPObservers,numPObservers);
        LP0 = cat(2,LP,padding);
        padding = zeros(numOutputsJObservers-numOutputsPObservers,1,numPObservers);
        PAttack0 = cat(1,PAttack,padding);
        
        % Create page arrays of each ApLC
        MOstruct.numSystems = numJObservers+numPObservers+1;
        ApLC3D = cat(3,sysA,ApLCJ,ApLCP);
        LC3D   = cat(3,zeros(size(LCJ(:,:,1))),LCJ,LCP);
        L3D    = cat(3,zeros(size(LJ(:,:,1))),LJ,LP0);
        attack3D = cat(3,zeros(size(JAttack(:,:,1))),JAttack,PAttack0);
        B3D    = repmat(sysB,1,1,MOstruct.numSystems);
        u3D    = repmat(u,1,1,MOstruct.numSystems);
    end

    % Initial condition is the first n elements of x0Options, xhat initial
    % conditions are always 0
    if size(x0Options,1) < numOriginalStates
        error('There are more states than initial conditions.')
    end
    X0 = zeros(numOriginalStates*(1+numPObservers+numJObservers)+size(THE_A,1),1);
    X0(1:numOriginalStates,:) = x0Options(1:numOriginalStates,1);
    
    % solve system
    [t,X] = ode45(@(t,X) ssMOodeFunSetup(t,X,u,u3D,attack,attack3D,THE_A,THE_B,COutputs,ApLC3D,B3D,LC3D,L3D,MOstruct),tspan,X0);
    t = t';
    X = X';
    
    state = X(1:numOriginalStates,:);
    CMO3Destimates = X(numOriginalStates+1:end-size(THE_A,1),:);
    SSMOz = X(end-size(THE_A,1)+1:end,:);
    SSMOestimates = flatten(pagemtimes(T(:,:,2:end),SSMOz));
    
    % calculate difference
    diff = CMO3Destimates - SSMOestimates;
    score = max(max(diff));
    disp(score)
    if score < 1e-3
        disp('Tolerance within numerical tolerance.')
    else
        disp('The solutions are not similar.')
    end
end
