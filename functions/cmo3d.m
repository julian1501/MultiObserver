classdef cmo3d
% CMO3D Class
%
% The 'cmo3d' class creates a 3D Conventional Multi-Observer (CMO) system 
% by combining a system object ('sys'), a set of J-observers ('Jmo'), and a
% set of P-observers ('Pmo'). The observers are stored in 3D arrays
%
% This documentation was written by ChatGPT.
%
% Syntax:
% -------
% 'obj = cmo3d(sys, Jmo, Pmo)'
%
% Inputs:
% -------
% - 'sys' (msd object): 
%   The system object containing all relevant system details.
%
% - 'Jmo' (mo object): 
%   An object containing the J-observers.
%
% - 'Pmo' (mo object): 
%   An object containing the P-observers.
%
% Properties:
% -----------
% - 'Name' (string): 
%   A descriptive name for the system, initialized as ''3D-CMO''.
%
% - 'sys' (msd object): 
%   The input system object.
%
% - 'numObservers' (integer): 
%   The total number of observers, calculated as the sum of J-observers and P-observers.
%
% - 'numOutputs' (integer): 
%   The total number of outputs.
%
% - 'ApLC' (3D array): 
%   The 'A+LC' matrices for each observer, stacked along the third dimension.
%
% - 'LC' (3D array): 
%   The 'LC' matrices for each observer, stacked along the third dimension.
%
% - 'C' (3D array): 
%   The 'C' matrices for each observer, stacked along the third dimension.
%
% - 'L' (3D array): 
%   The 'L' matrices for each observer, stacked along the third dimension, with appropriate padding for alignment.
%
% - 'attack' (3D array): 
%   The attack list ('Attack.attackList') sliced based on the outputs for each observer, stacked along the third dimension.
%
% - 'B' (3D array): 
%   The shared input matrix for all observers, repeated along the third dimension.
%
% - 'E' (3D array): 
%   The shared nonlinear contribution matrix for all observers, repeated along the third dimension.
%
% - 'x0' (array): 
%   Initial conditions for the observers (not explicitly initialized in the constructor).
%
% - 'Attack' (attack object): 
%   The attack object associated with the system, inherited from 'Jmo'.
%
% Methods:
% --------
% - cmo3d(sys, Jmo, Pmo): 
%   Constructor method that initializes the 'cmo3d' object, combining the properties of the 'sys', 'Jmo', and 'Pmo' inputs.
%   Key steps:
%     - Retrieves and combines the 'ApLC' and 'LC' matrices for J- and P-observers using the 'systemStarSetup3D' function.
%     - Aligns dimensions of matrices ('C', 'L', 'attack') by adding appropriate padding.
%     - Constructs shared properties ('B', 'E') by replicating the respective matrices from 'sys'.
%
% Example Usage:
% --------------
% sys = msd();         % Create a system object
% Jmo = mo();          % Define a set of J-observers
% Pmo = mo();          % Define a set of P-observers
% cmo = cmo3d(sys, Jmo, Pmo); % Create a 3D-CMO object
%
% Notes:
% ------
% - This class assumes the availability of the 'systemStarSetup3D' function for processing observer matrices.
% - Padding ensures that the dimensions of J- and P-observer matrices align correctly for stacking operations.
% - The 'Attack' property directly links to the attack object of the 'Jmo'.
%
% Dependencies:
% -------------
% - systemStarSetup3D.m : External function required for processing observer matrices.
% - msd.m and mo.m: Classes representing the system and observer models, respectively.
%
% See Also:
% ---------
% - ssmo.m : Related class or function (as mentioned in the header comment).


    properties
        Name
        sys
        numObservers
        numOutputs
        ApLC
        LC
        C
        L
        attack3d
        B
        E
        x0
        Attack
        Jmo
        Pmo
    end

    methods
        function obj = cmo3d(sys,Jmo,Pmo)
            obj.sys = sys;
            obj.Name = '3D-CMO';
            obj.Attack = Jmo.Attack;
            obj.numObservers = Jmo.numObservers + Pmo.numObservers;
            obj.numOutputs = Jmo.numOutputs;
            obj.Jmo = Jmo;
            obj.Pmo = Pmo;
            

            [ApLCJ,LCJ] = ApLCSetup(Jmo);
            [ApLCP,LCP] = ApLCSetup(Pmo);

            % Pad the right side of LP with zeros to match the cross sectional size of
            % LJ
            padding = zeros(Jmo.numOutputsObservers-Pmo.numOutputsObservers,Jmo.nx,Pmo.numObservers);
            obj.C = cat(3,Jmo.Ci,cat(1,Pmo.Ci,padding));
            padding = zeros(Jmo.nx,Jmo.numOutputsObservers-Pmo.numOutputsObservers,Pmo.numObservers);
            PmoLPadded = cat(2,Pmo.Li,padding);
            padding = zeros(Jmo.numOutputsObservers-Pmo.numOutputsObservers,1,Pmo.numObservers);
            PAttackPadded = cat(1,Pmo.attack3d,padding);
            
            
            % Create page arrays of each ApLC
            obj.ApLC = cat(3,ApLCJ,ApLCP);
            obj.LC   = cat(3,LCJ,LCP);
            obj.L    = cat(3,Jmo.Li,PmoLPadded);
            obj.attack3d = cat(3,Jmo.attack3d,PAttackPadded);
            obj.B    = repmat(sys.B,1,1,obj.numObservers);
            obj.E    = repmat(sys.E,1,1,obj.numObservers);
            
        end

    end

end