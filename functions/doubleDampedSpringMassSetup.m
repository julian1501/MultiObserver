function [system,A,B,C,D] = doubleDampedSpringMassSetup(mass1,mass2,springConstant1,springConstant2,dampingConstant1,dampingConstant2,J)
    % This function sets up a damped mass spring system.

    A = [0 1 0 0;
        -(springConstant1+springConstant2)/mass1, -(dampingConstant1+dampingConstant2)/mass1, springConstant2/mass1, dampingConstant2/mass1;
        0 0 0 1;
        springConstant2/mass2, dampingConstant2/mass2, -springConstant2/mass2, -dampingConstant2/mass2];
    
    B = [0; 
        0;
        0;
        1/mass2];
    n = size(A,1);
    C = zeros(J,n);
    I = eye(n);
    if J < n
        C(1:J,1:n) = I(1:J,1:n);
    else
        C(1:n,1:n) = I(1:n,1:n);
    end
    D = 0;

    system = ss(A,B,C,D);

end