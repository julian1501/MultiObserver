function [Ap,Bp] = systemPSetup(A,C,L,LTilde,setString,MOstruct)
    % [Ap,Bp] = systemPSetup(A,C,LTilde,setString,CMOstruct) defines the Ap
    % and Bp matrices. Where each layer of Ap is
    % A(:,:,i)+L(:,:,i)*C(:,:,i). And Bp is LTilde when there is no
    % non-linearity.
    
    [numObservers, ~] = selectObserverSpecs(setString,MOstruct);
    
    Ap = zeros(MOstruct.numOriginalStates,MOstruct.numOriginalStates,numObservers);
    Bp = LTilde;

    for i = 1:1:numObservers
        Ap(:,:,i) = A(:,:,i) + L(:,:,i)*C(:,:,i);
    end

end