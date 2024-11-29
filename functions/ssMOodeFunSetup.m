function dX = ssMOodeFunSetup(t,X,u,u3D,a,a3D,ssmoA,ssmoB,C,ApLC,B3D,LC,L,MOstruct)
    % This function sets up a differential equation that can be used in an
    % ode45 solver. Takes A and B matrices as an input and the input u at
    % that time.
    dX = zeros(size(X));
    ssmo_size = size(ssmoA,1);
    attack = attackFunction(t,a);
    attack3D = attackFunction(t,a3D);

    % 3D CMO
    x3D = reshape(X(1:end-ssmo_size),MOstruct.numOriginalStates,1,MOstruct.numSystems);
    dx3D = pagemtimes(ApLC,x3D) - pagemtimes(LC,x3D(:,:,1)) + pagemtimes(B3D,u3D) - pagemtimes(L,attack3D);
    dX(1:end-ssmo_size) = dx3D(:);
    
    % SSMO
    l = MOstruct.numOriginalStates;
    z = X(end-ssmo_size+1:end);
    y = C*X(1:l);
    
    dX(end-ssmo_size+1:end) = ssmoA*z - ssmoB*(y+attack);

  
end