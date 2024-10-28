function [system,A,B,C,D] = dampedSpringMassSetup(mass,springConstant,dampingConstant)
    % This function sets up a damped mass spring system.

    A = [0, 1; -springConstant/mass, -dampingConstant/mass];
    B = [0; 1/mass];
    % C should contain all rows that are valid outputs all rows should
    % individu
    C = [1 0;
         0 1];
    D = 0;

    system = ss(A,B,C,D);

end