function [ds] = ssSSMOodeFunSetup(t,s,a,sysA,ssmoA,ssmoB,C,T,PsubsetOfJIndices,MOstruct)
    % This function sets up a differential equation that can be used in an
    % ode45 solver. Takes A and B matrices as an input and the input u at
    % that time.
    l = MOstruct.numOriginalStates;
    x = s(1:l);
    z = s(l+1:end);
    y = C*s(1:l);
    attack = attackFunction(t,a);
    
    xhat = pagemtimes(T,z);
    zhat = selectBestEstimate(xhat(:),1,PsubsetOfJIndices,MOstruct);

    ds1 = sysA*x;
    ds2 = ssmoA*z - ssmoB*(y+attack);
    ds = [ds1;ds2];
end