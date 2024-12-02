function [Ap,Bp] = systemPSetup(mo,Lpadded)
    % [Ap,Bp] = systemPSetup(A,C,LTilde,setString,CMOstruct) defines the Ap
    % and Bp matrices. Where each layer of Ap is
    % A(:,:,i)+L(:,:,i)*C(:,:,i). And Bp is LTilde when there is no
    % non-linearity.
    
    Ap = zeros(mo.nx,mo.nx,mo.numObservers);
    Bp = Lpadded;

    for i = 1:1:mo.numObservers
        Ap(:,:,i) = mo.Ai(:,:,i) + mo.Li(:,:,i)*mo.Ci(:,:,i);
    end

end