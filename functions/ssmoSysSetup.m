function [A,B] = ssmoSysSetup(q,ssmo)
    
    topA = -1.*q;
    bottomA = [eye(ssmo.sys.nx-1) zeros(ssmo.sys.nx-1,1)];
    Avalues = [topA; bottomA];
    I = eye(ssmo.numOutputs);
    A = kron(Avalues,I);

    Bvalues = [1; zeros(ssmo.sys.nx-1,1)];
    B = kron(Bvalues,I);

end