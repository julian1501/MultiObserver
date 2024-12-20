function [x,t] =  CMO3D(dialog,plot)
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
    
    
    %% CALCULATIONS
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
    sys = msd(true,sysNum,0.5,5,0.6);

    if ~isMatrixStable(sys.A)
        warning('The system is unstable')
    end
    if sys.D ~= 0
        error('Implementation for systems with D still needs work.')
    end

    Attack = attack(numOutputs,numAttackedOutputs);
    
    % define a dictionary that stores all info
    MOstruct.numOutputs              = numOutputs;
    MOstruct.numAttackedOutputs      = numAttackedOutputs;
    MOstruct.numOutputsJObservers    = numOutputsJObservers;
    MOstruct.numJObservers           = numJObservers;
    MOstruct.numOutputsPObservers    = numOutputsPObservers;
    MOstruct.numPObservers           = numPObservers;
    MOstruct.numOriginalStates       = sys.nx;
    MOstruct.numOriginalInputs       = sys.nu;
    MOstruct.numOriginalOutputs      = sys.ny;
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
    
    [AJ,LJ] = systemJSetup(sys.A,CJ,eigenvalueOptions,'J',MOstruct);
    [AP,LP] = systemJSetup(sys.A,CP,eigenvalueOptions,'P',MOstruct);
    [ApLCJ,LCJ] = systemStarSetup3D(AJ,LJ,CJ,'J',MOstruct);
    [ApLCP,LCP] = systemStarSetup3D(AP,LP,CP,'P',MOstruct);
    
    % Pad the right side of LP with zeros to match the cross sectional size of
    % LJ
    padding = zeros(numOriginalStates,numOutputsJObservers-numOutputsPObservers,numPObservers);
    LP0 = cat(2,LP,padding);
    padding = zeros(numOutputsJObservers-numOutputsPObservers,1,numPObservers);
    PAttack0 = cat(1,PAttack,padding);
    
    % Create page arrays of each ApLC
    ApLC3D = cat(3,sysA,ApLCJ,ApLCP);
    LC3D   = cat(3,zeros(size(LCJ(:,:,1))),LCJ,LCP);
    L3D    = cat(3,zeros(size(LJ(:,:,1))),LJ,LP0);
    attack3D = cat(3,zeros(size(JAttack(:,:,1))),JAttack,PAttack0);
    B3D    = repmat(sysB,1,1,MOstruct.numSystems);
    u3D    = repmat(u,1,1,MOstruct.numSystems);
    
    % Initial condition is the first n elements of x0Options, xhat initial
    % conditions are always 0
    if size(x0Options,1) < numOriginalStates
        error('There are more states than initial conditions.')
    end
    x0 = zeros(numOriginalStates,1,numJObservers+numPObservers+1);
    x0(:,:,1) = x0Options(1:numOriginalStates,1);
    
    
    % solve system
    [t,x] = ode45(@(t,x) ss3DMOodeFunSetup(t,x,u3D,attack3D,ApLC3D,B3D,LC3D,L3D,PsubsetOfJIndices,MOstruct),tspan,x0);
    t = t';
    x = x';
    
    % find estimate after the fact, the estimate is also found at each timestep
    % within the ssODEfunSetup for feedback purposes
    steps = size(x,2);
    [estimate, ~] = selectBestEstimate(x,steps,PsubsetOfJIndices,MOstruct);
    err = x(1:numOriginalStates,:) - estimate;
    fprintf('The error at the final time step is: %2.20f \n',err(:,end))
    
    if plot
        MOplot(t,x,err,estimate,sys.Name,MOstruct);
    end
end

