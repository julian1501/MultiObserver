function [dx,xhat] = ssCMOodeFunSetup(t,x,eta,A,E,PsubsetOfJIndices,CMOstruct)
    % This function sets up a differential equation that can be used in an
    % ode45 solver. Takes A and B matrices as an input and the input u at
    % that time.
    
    xhat = selectBestEstimate(x,1,PsubsetOfJIndices,CMOstruct);
    dx = A*x + E*eta;
end