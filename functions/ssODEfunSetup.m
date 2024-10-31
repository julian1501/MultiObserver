function dx = ssODEfunSetup(t,x,u,A,B,PsubsetOfJIndices,CMOdict)
    % This function sets up a differential equation that can be used in an
    % ode45 solver. Takes A and B matrices as an input and the input u at
    % that time.
    numOriginalStates = CMOdict('numOriginalStates');
    dx = zeros(numOriginalStates+size(A,1),1);
    dx(1:numOriginalStates,:) = selectBestEstimate(x,PsubsetOfJIndices,CMOdict);
    dx(numOriginalStates+1:end,:) = A*x(numOriginalStates+1:end,:) + B*u;
end