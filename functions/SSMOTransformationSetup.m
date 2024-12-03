function T = SSMOTransformationSetup(Ap,Bp,q,mo)
       
    a = mo.nx*(mo.numOutputs + mo.sys.NLsize);
    c = mo.nx;
    
    Rp = zeros(c,a,mo.numObservers);
    for i = 1:1:mo.numObservers
       Rp(:,:,i) = ctrb(Ap(:,:,i),Bp(:,:,i));
    end

    I = eye(mo.numOutputs + mo.sys.NLsize);
    RqValues = zeros(mo.nx);

    for i = 1:1:mo.nx
        newRow = [zeros(1,i-1) 1 q(1:end-1)];
        RqValues(i,:) = newRow(1:mo.nx);
    end

    % multiply all individual eigenvalues by the appropriatly sized
    % identity matrix
    Rq = kron(RqValues,I);

    % Create all T matrices by multiplying Rp and Rq
    T = zeros(mo.nx,(mo.numOutputs + mo.sys.NLsize)*mo.nx,mo.numObservers);
    for i = 1:1:mo.numObservers
        T(:,:,i) = Rp(:,:,i)*Rq;
    end

end