function [cmoSystem,sol,t,numCMOStates,numCMOInputs,numCMOOutputs] = cmoSolution(sys, t, numOutputs, numObservers, sizeObservers, originalSIO)
    
    numOriginalStates  = originalSIO(1);
    numOriginalInputs  = originalSIO(2);
    numOriginalOutputs = originalSIO(3);
    % Create a multi observer with sizeObserver-sized sets
    cmoSystem = subSetCMOSetup(sys,sizeObservers,numOutputs);
    Astar = cmoSystem.A;
    Bstar = cmoSystem.B;
    Cstar = cmoSystem.C;
    numCMOStates = size(Astar,1);
    numCMOInputs = size(Bstar,2);
    numCMOOutputs = size(Cstar,1);
    
    
    % simulate system
    u = zeros(numOriginalInputs,size(t,2));
    eta = etaSetup(u,numObservers,numOriginalStates,sizeObservers,0.01,0);
    % Initial condition is the first n elements of x0Options, xhat initial
    % conditions are always 0
    x0 = zeros(numCMOStates,1);
    x0Options = [0.3;-0.1;-0.2;0.15;0.18;0.1;-0.25;0.2];
    x0(1:numOriginalOutputs,1) = x0Options(1:numOriginalOutputs,1);
    
    sol = lsim(cmoSystem,eta,t,x0)';
end