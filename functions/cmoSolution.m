function [cmoSystem,sol,CJIndices,CMOdict] = cmoSolution(sys, t,setString,CMOdict)
    % This function takes in 
    %   sys: a state space system created by ss(A,B,C,D);
    %   t: a time series
    %   setString: a string that is either 'P' or 'J' indicating which set
    %       is being set up
    %   CMOdict: a dictionary that stores information about the CMO

    % Extract variables from the CMOdict
    numOutputs = CMOdict('numOutputs');
    [numObservers, numOutputsObserver] = selectObserverSpecs(setString,CMOdict);
    numOriginalStates  = CMOdict('numOriginalStates');
    numOriginalInputs  = CMOdict('numOriginalInputs');
    numOriginalOutputs = CMOdict('numOriginalOutputs');

    % Create a multi observer with sizeObserver-sized sets
    fprintf(['Setting up CMO system for ' setString ' sized sets. \n'])
    [cmoSystem,~,~,~,~,CJIndices] = subSetCMOSetup(sys,setString,CMOdict);
    Astar = cmoSystem.A;
    Bstar = cmoSystem.B;
    Cstar = cmoSystem.C;
    
    numCMOStates = size(Astar,1);
    numCMOInputs = size(Bstar,2);
    numCMOOutputs = size(Cstar,1);
    if setString == 'J'
        CMOdict('numCMOStatesJ') = numCMOStates;
        CMOdict('numCMOInputsJ') = numCMOInputs;
        CMOdict('numCMOOutputsJ') = numCMOOutputs;
    elseif setString == 'P'
        CMOdict('numCMOStatesP') = numCMOStates;
        CMOdict('numCMOInputsP') = numCMOInputs;
        CMOdict('numCMOOutputsP') = numCMOOutputs;
    end

    % only solve the system when a time series is provided
    if t == 0
        fprintf('System will not be solved.\n')
        sol = nan;
    else
        fprintf(['System ' setString ' is being solved. \n'])
        % simulate system
        u = zeros(numOriginalInputs,size(t,2));
        eta = etaSetup(u,0,0,setString,CMOdict);
        % Initial condition is the first n elements of x0Options, xhat initial
        % conditions are always 0
        x0 = zeros(numCMOStates,1);
        x0Options = [0.3;-0.1;-0.2;0.15;0.18;0.1;-0.25;0.2];
        x0(1:numOriginalOutputs,1) = x0Options(1:numOriginalOutputs,1);
        sol = lsim(cmoSystem,eta,t,x0)';
    end
end