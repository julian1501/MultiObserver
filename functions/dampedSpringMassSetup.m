function [system,A,B,C,D] = dampedSpringMassSetup(mass,springConstant,dampingConstant,J)
    % This function sets up a damped mass spring system.

    A = [0, 1; -springConstant/mass, -dampingConstant/mass];
    B = [0; 1/mass];
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