function [cmoSystem,sol,CJIndices,CMOdict] = cmoSolution(sys,tspan,solver,setString,CMOdict)
    % This function takes in 
    %   sys: a state space system created by ss(A,B,C,D);
    %   t: a time series
    %   solver: either 'lsim' or 'ode45'
    %   setString: a string that is either 'P' or 'J' indicating which set
    %       is being set up
    %   CMOdict: a dictionary that stores information about the CMO

    % Check whether one of the correct solvers is given
    if ~(matches(solver,'lsim') || matches(solver,'ode45'))
        error('Solver should be lsim or ode45',solver)
    end

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

    % Initial condition is the first n elements of x0Options, xhat initial
    % conditions are always 0
    x0 = zeros(numCMOStates,1);
    x0Options = [0.3;-0.1;-0.2;0.15;0.18;0.1;-0.25;0.2];
    x0(1:numOriginalOutputs,1) = x0Options(1:numOriginalOutputs,1);

    % only solve the system when a time series is provided
    if tspan == 0
        fprintf('System will not be solved, because t=0.\n')
        sol = nan;
    elseif matches(solver,'lsim')
        fprintf(['System ' setString ' is being solved. \n'])
        % simulate system
        u = zeros(numOriginalInputs,size(tspan,2));
        eta = etaSetup(u,0,0,setString,CMOdict);

        sol = lsim(cmoSystem,eta,tspan,x0)';
    elseif matches(solver,'ode45')
        odeTspan = [tspan(1) tspan(end)];
        [t,x] = ode45(@(t,x) stateSpaceSetup(t,x,Astar),odeTspan,x0);
    end
end