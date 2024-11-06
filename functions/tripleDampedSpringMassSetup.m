function [system,sysName,A,B,C,D] = tripleDampedSpringMassSetup(mass,springConstant,dampingConstant)
    % This function sets up a damped mass spring system.
    sysName = "Triple mass-spring-damper";
    
    m1 = mass(1); m2 = mass(2); m3 = mass(3);
    k1 = springConstant(1); k2 = springConstant(2); k3 = springConstant(3);
    c1 = dampingConstant(1); c2 = dampingConstant(2); c3 = dampingConstant(3);

    A = [0 1 0 0 0 0;
        -(k1+k2)/m1, -(c1+c2)/m1, k2/m1, c2/m1 0 0;
        0 0 0 1 0 0;
        k2 c2 -(k2+k3)/m2, -(c2+c3)/m2, k3/m2, c3/m2;
        0 0 0 0 0 1;
        0 0 k3/m3 c3/m3 -k3/m3 -c3/m3];
    
    B = [ 0    0    0  ; 
         1/m1  0    0  ;
          0    0    0  ;
          0   1/m2  0  ;
          0    0    0  ;
          0    0   1/m3];

    % C should contain all rows that are valid outputs
    C = [1 0 0 0 0 0;
         1 0 1 0 0 0;
         1 0 1 0 1 0];

    system = ss(A,B,C,0);

end