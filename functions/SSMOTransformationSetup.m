function T = SSMOTransformationSetup(Ap,Bp,q,setString,MOstruct)
    
    [numObservers, ~] = selectObserverSpecs(setString,MOstruct);
    
    a = MOstruct.numOriginalStates*MOstruct.numOutputs;
    c = MOstruct.numOriginalStates;
    
    Rp = zeros(c,a,numObservers);
    for i = 1:1:numObservers
       Rp(:,:,i) = ctrb(Ap(:,:,i),Bp(:,:,i));
    end

    I = eye(MOstruct.numOutputs);
    RqValues = zeros(MOstruct.numOriginalStates);

    for i = 1:1:MOstruct.numOriginalStates
        newRow = [zeros(1,i-1) 1 q(1:end-1)];
        RqValues(i,:) = newRow(1:MOstruct.numOriginalStates);
    end

    % multiply all individual eigenvalues by the appropriatly sized
    % identity matrix
    Rq = kron(RqValues,I);

    % Create all T matrices by multiplying Rp and Rq
    T = zeros(MOstruct.numOriginalStates,MOstruct.numOutputs*MOstruct.numOriginalStates,numObservers);
    for i = 1:1:numObservers
        T(:,:,i) = Rp(:,:,i)*Rq;
    end

end