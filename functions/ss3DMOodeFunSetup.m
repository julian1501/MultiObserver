function [dx] = ss3DMOodeFunSetup(t,x,u,a,ApLC,B,LC,L,PsubsetOfJIndices,CMOstruct)
    % This function sets up a differential equation that can be used in an
    % ode45 solver. Takes A and B matrices as an input and the input u at
    % that time.
    x3D = reshape(x,CMOstruct.numOriginalStates,1,CMOstruct.numSystems);
    xhat = selectBestEstimate(x3D(:),1,PsubsetOfJIndices,CMOstruct);
    attack = attackFunction(t,a);
    dx3D = pagemtimes(ApLC,x3D) - pagemtimes(LC,x3D(:,:,1)) + pagemtimes(B,u) - pagemtimes(L,attack);
    dx = dx3D(:);
end