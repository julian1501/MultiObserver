function [dx,xhat] = ssCMOodeFunSetup(t,x,u,A,B,PsubsetOfJIndices,CMOdict)
    % This function sets up a differential equation that can be used in an
    % ode45 solver. Takes A and B matrices as an input and the input u at
    % that time.
%     numOriginalStates = CMOdict("numOriginalStates");
    xhat = selectBestEstimate(x,1,PsubsetOfJIndices,CMOdict);
    dx = A*x + B*u;
end