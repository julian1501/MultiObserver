function [Ap,Bp] = systemPSetup(mo,Lpadded)
    % [Ap,Bp] = systemPSetup(A,C,LTilde,setString,CMOstruct) defines the Ap
    % and Bp matrices. Where each layer of Ap is
    % A(:,:,i)+L(:,:,i)*C(:,:,i). And Bp is LTilde when there is no
    % non-linearity.
    
    Ap = zeros(mo.nx,mo.nx,mo.numObservers);
    if size(mo.sys.E,2) > 0
        Bp = [repmat(mo.sys.E,1,1,size(Lpadded,3)),-Lpadded];
    else
        Bp = -Lpadded;
    end

    for i = 1:1:mo.numObservers
        Ap(:,:,i) = mo.Ai(:,:,i) + mo.Li(:,:,i)*mo.Ci(:,:,i);
    end

end