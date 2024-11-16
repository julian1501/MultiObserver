function [ATilde,LC] = systemStarSetup3D(Aset,Lset,Cset,setString,CMOstruct)
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
    
    numOriginalStates = CMOstruct.numOriginalStates;
    [numObservers,~] = selectObserverSpecs(setString,CMOstruct);
    
    % Define Bstar
    LC = zeros(numOriginalStates,numOriginalStates,numObservers);
    
    % Create empty matrix to store A's on the diagonal
    ATilde =  zeros(numOriginalStates,numOriginalStates,numObservers);

    % Add LjCj from Aj and place on the diagonal
    for l = 1:1:numObservers
        LCl = Lset(:,:,l)*Cset(:,:,l);
        ATilde(:,:,l) = Aset(:,:,l) + LCl;
        LC(:,:,l) = LCl;
    end

end