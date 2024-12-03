function x0 = x0setup(x0input,whichMO,sys,Jmo,Pmo)
    
    x0sys = x0input(1:sys.nx);
    numObservers = Jmo.numObservers + Pmo.numObservers;
    if whichMO(1) == 1
        x0cmo2d = zeros(numObservers*sys.nx,1);
    else
        x0cmo2d = [];
    end

    if whichMO(2) == 1
        x0cmo3d = zeros(sys.nx,1,numObservers,1);
    else
        x0cmo3d = [];
    end

    if whichMO(3) == 1
        x0ssmo = zeros(sys.nx*(Jmo.numOutputs + sys.NLsize),1);
    else
        x0ssmo = [];
    end
    
    x0 = [x0sys(:); x0cmo2d(:); x0cmo3d(:); x0ssmo(:)];
end