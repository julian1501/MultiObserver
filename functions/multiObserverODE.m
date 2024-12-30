function dx = multiObserverODE(sys,t,x,Attack,CMO2D,CMO3D,SSMO,whichMO)
% multiObserverODE Function
%
% The 'multiObserverODE' function computes the time derivative of the system 
% state ('dx') for a dynamic system with potential attacks and multiple types 
% of observers, including 2D-CMO, 3D-CMO, and SSMO. Active observers are 
% specified using the 'whichMO' array.
% 
% This documentation was written by ChatGPT.
%
% Syntax:
% -------
% 'dx = multiObserverODE(sys, t, x, Attack, CMO2D, CMO3D, SSMO, whichMO)'
%
% Inputs:
% -------
% - 'sys': System model structure containing:
%    - 'nx': Number of states.
%    - 'A': State transition matrix.
%    - 'COutputs': Output matrix.
%    - 'E': Coupling matrix for nonlinear components.
%    - 'NLsize': Size of nonlinear dynamics (if any).
%    - 'Linear': Logical flag indicating if the system is linear.
% - 't': Current time (scalar).
% - 'x': State vector, containing:
%    - 'xsys': System states.
%    - States for 'CMO2D', 'CMO3D', and 'SSMO' observers (if active).
% - 'Attack': Attack model structure containing:
%    - 'attackList': Vector specifying attack signals.
% - 'CMO2D': Configuration for the 2D observer (optional).
% - 'CMO3D': Configuration for the 3D observer, containing:
%    - 'numObservers': Number of 3D observers.
%    - 'ApLC': Observer dynamics matrix.
%    - 'LC', 'L': Gain matrices.
%    - 'E': Coupling matrix for nonlinear components.
%    - 'attack': Attack signals for 3D observer.
% - 'SSMO': Configuration for the SSMO observer (optional).
% - 'whichMO': Boolean array specifying active observers:
%    - 'whichMO(1)': Use 'CMO2D' (1 = active, 0 = inactive).
%    - 'whichMO(2)': Use 'CMO3D' (1 = active, 0 = inactive).
%    - 'whichMO(3)': Use 'SSMO' (1 = active, 0 = inactive).
%
% Outputs:
% --------
% - 'dx': Time derivative of all states, including system and observer 
%   states (vector).
%
% Observer Dynamics:
% ------------------
% 1. System State ('dxsys'):
%    - If nonlinear components are present ('NLsize > 0'), 'dxsys' includes 
%      the dynamics of nonlinear springs.
%    - Otherwise, 'dxsys' depends only on the system matrix 'A'.
% 2. 2D-CMO Dynamics ('dxcmo2d'):
%    - Currently inactive (placeholder).
% 3. 3D-CMO Dynamics ('dxcmo3d'):
%    - Includes attack signals, nonlinear contributions, and coupling terms 
%      defined in 'CMO3D'.
% 4. SSMO Dynamics ('dxssmo'):
%    - Includes nonlinear dynamics and attack signals, with coupling through 
%      'SSMO.B'.
%
% Notes:
% ------
% - Ensure input dimensions are consistent with system and observer models.
% - Attack dynamics are applied via 'attackFunction'.
% - Nonlinear spring dynamics are applied using 'NLspring'.
%
% See also:
% -------------
% NLspring.m, attackFunction.m, cmo3d.m, ssmo.m


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
        Attack3d = attackFunction(t,CMO3D.attack3d);
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