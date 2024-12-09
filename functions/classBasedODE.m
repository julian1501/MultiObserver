function dx = classBasedODE(sys,t,x,Attack,CMO2D,CMO3D,SSMO,whichMO)
    
    % Caluclate dx for the system
    xsys = x(1:sys.nx);
    y = sys.COutputs*xsys;
    a = attackFunction(t,Attack.attackList);
    if sys.NLsize > 0
        dxsys = sys.A*xsys + sys.E*NLspring(sys,y);
    else
        dxsys = sys.A*xsys;
    end

    sxcmo2dStart = sys.nx + 1;
    placeholder = 0;
    xcmo2dEnd   = sys.nx + placeholder*sys.nx;
    xcmo3dStart = xcmo2dEnd + 1;
    xcmo3dEnd   = xcmo2dEnd + CMO3D.numObservers*sys.nx;
    xssmoStart  = xcmo3dEnd + 1;
    xssmoEnd    = xcmo3dEnd + (sys.NLsize + SSMO.numOutputs)*sys.nx;

    % Calculations for the CMO2D
%     if whichMO(1) == 1
%         xcmo2d = x(xcmo2dStart:xcmo2dEnd);
%         dxcmo2d = CMO2D.A*[xsys; xcmo2d];
%     else
%         dxcmo2d = [];
%     end
    dxcmo2d = [];
    
    % Calculations for the CMO3D
    if whichMO(2) == 1
        xcmo3d = reshape(x(xcmo3dStart:xcmo3dEnd),sys.nx,1,CMO3D.numObservers);
        Attack3d = attackFunction(t,CMO3D.attack);
        phi = NLspring(sys,y+a);

        dxcmo3d = pagemtimes(CMO3D.ApLC,xcmo3d) - pagemtimes(CMO3D.LC,xsys) - pagemtimes(CMO3D.L,Attack3d);

        if ~sys.Linear
            dxcmo3d = dxcmo3d +  pagemtimes(CMO3D.E,phi);
        end
        
    else
        dxcmo3d = [];
    end
    
    % Calculations for the SSMO
    if whichMO(3) == 1
        xssmo = x(xssmoStart:xssmoEnd);
        dxssmo = SSMO.A*xssmo + SSMO.B*([NLspring(sys,y+a) ;y] + [zeros(sys.NLsize,1) ;a]); 
    else
        dxssmo = [];
    end

    dx = [dxsys(:); dxcmo2d(:); dxcmo3d(:); dxssmo(:)];

end