function [ATilde,LC] = systemStarSetup(Aset,Lset,Cset,setString,CMOdict)
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
    
    numOriginalStates = CMOdict("numOriginalStates");
    [numObservers,~] = selectObserverSpecs(setString,CMOdict);
    
    % Define Bstar
    LC = zeros(numOriginalStates*numObservers,numOriginalStates);
    
    % Create empty matrix to store A's on the diagonal
    ATilde =  zeros(numOriginalStates*numObservers);

    % Add LjCj from Aj and place on the diagonal
    for l = 1:1:numObservers
        Start = (l-1)*(numOriginalStates) + 1;
        End   = (l-1)*(numOriginalStates) + numOriginalStates;
        LCl = Lset(:,:,l)*Cset(:,:,l);
        ATilde(Start:End,Start:End) = Aset(:,:,l) + LCl;
        LC(Start:End,:) = LCl;
    end

    ATilde = sparse(ATilde);

end