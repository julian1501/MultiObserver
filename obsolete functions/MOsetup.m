function [x,t] = MOsetup(dialog,plot)
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
    
    % Define system input
    u = zeros(MOstruct.numOriginalInputs,1);
    
    % Setup outputs and noise 
    COutputs = CNSetup(sys,numOutputs);
    attack = attackSetup(MOstruct);
    [CJ,CJIndices,~] = CsetSetup(COutputs,attack,'J',MOstruct);
    [CP,CPIndices,~] = CsetSetup(COutputs,attack,'P',MOstruct);
    
    % find which p observers are subsets of each j observer
    [numOfPsubsetsInJ, PsubsetOfJIndices] = findIndices(CJIndices,CPIndices,MOstruct);
    MOstruct.numOfPsubsetsInJ = numOfPsubsetsInJ;
    
    eigenvalues = eigenvalueOptions(1:numOriginalStates);
    [AJ,LJ] = systemJSetup(sysA,CJ,eigenvalues,'J',MOstruct);
    [AP,LP] = systemJSetup(sysA,CP,eigenvalues,'P',MOstruct);
    
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
    
    % Initial condition is the first n elements of x0Options, xhat initial
    % conditions are always 0
    if size(x0Options,1) < numOriginalStates
        error('There are more states than initial conditions.')
    end
    s0 = zeros(numOriginalStates+size(THE_A,1),1);
    s0(1:numOriginalStates,:) = x0Options(1:numOriginalStates,1);
    
    % solve system
    [t,s] = ode45(@(t,s) ssSSMOodeFunSetup(t,s,attack,sysA,THE_A,THE_B,COutputs,T,PsubsetOfJIndices,MOstruct),tspan,s0);
    t = t';
    s = s';
    
    state = s(1:numOriginalStates,:);
    transformedEstimates = s(numOriginalStates+1:end,:);
    
    % transfer estimates into standard coordinate system
    x = flatten(pagemtimes(T,transformedEstimates));
    x(1:MOstruct.numOriginalStates,:) = state;
    
    
    % find estimate after the fact, the estimate is also found at each timestep
    % within the ssODEfunSetup for feedback purposes
    steps = size(x,2);
    [estimate, ~] = selectBestEstimate(x,steps,PsubsetOfJIndices,MOstruct);
    err = x(1:numOriginalStates,:) - estimate;
    fprintf('The error at the final time step is: %2.20f \n',err(:,end))
    
    if plot
      MOplot(t,x,err,estimate,sysName,MOstruct);
    end
end