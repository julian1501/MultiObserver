function [ApLCi,LCi] = systemStarSetup3D(mo)
    % [Aset,LC] = systemStarSetup(Aset,Lset,Cset,setString,CMOdict) sets up
    % the ATilde matrix that will be used to simulate the system and all
    % its observers. Aset is a matrix with copies of the original A along
    % its diagonal, the new matrix ATilde has the Aj+LjCj along its
    % diagonal.
    %
    % For example:
    %   - Aset = [A 0 0 0;
    %             0 A 0 0;
    %             0 0 A 0;
    %             0 0 0 A]
    %     Lset = [L1; L2; L3; L4];
    %     Cset = [C1 C2 C3 C4];
    %       -> ATilde = [A+L1C1   0      0      0   ;
    %                      0    A+L2C2   0      0   ;
    %                      0      0    A+L3C3   0   ;
    %                      0      0      0    A+L4C4]
    %          LC = [L1C1; L2C2; L3C3; L4C4]
    
    % Define empty LC
    LCi = zeros(mo.nx,mo.nx,mo.numObservers);
    
    % Create empty matrix to store A's on the diagonal
    ApLCi =  zeros(mo.nx,mo.nx,mo.numObservers);

    % Add LjCj from Aj and place on the diagonal
    for l = 1:1:mo.numObservers
        LCl = mo.Li(:,:,l)*mo.Ci(:,:,l);
        ApLCi(:,:,l) = mo.Ai(:,:,l) + LCl;
        LCi(:,:,l) = LCl;
    end

end