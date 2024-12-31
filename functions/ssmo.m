classdef ssmo
% ssmo Class
%
% The 'ssmo' class sets up a state-space multi-observer (SSMO) for a given 
% system, using provided configurations of primary (Jmo) and secondary 
% (Pmo) observers.
%
% Documentation written by ChatGPT.
%
% Properties:
% -----------
% - 'Name': A string representing the name of the SSMO object.
% - 'sys': The original system model for which the SSMO is constructed.
% - 'numOutputs': The number of outputs in the SSMO.
% - 'T': The transformation matrices for the observers.
% - 'A': The state-space A matrix for the overall SSMO system.
% - 'B': The state-space B matrix for the overall SSMO system.
% - 'COutputs': The output matrices for the observers.
% - 'Attack': Attack parameters from the primary observer (Jmo).
%
% Constructor ('ssmo'):
% ---------------------
% Creates an instance of the 'ssmo' class by integrating the primary (Jmo) 
% and secondary (Pmo) observer models into the overall SSMO framework.
%
% Inputs:
% -------
% - 'sys': The original system model (state-space representation).
% - 'Jmo': The primary observer model (with required observer properties).
% - 'Pmo': The secondary observer model (with required observer properties).
%
% Functionality:
% --------------
% 1. Stores the input 'sys' model and observer-related configurations in 
%    the SSMO object properties.
% 2. Pads the observer gain matrices ('LJ' and 'LP') to make them 
%    compatible with the full output.
% 3. Computes the transformed state-space matrices 'AJp', 'BJp' for the 
%    primary observer, and 'APp', 'BPp' for the secondary observer.
% 4. Derives the transformation matrices ('TJ' and 'TP') for the observers 
%    using the roots of the characteristic polynomial derived from the 
%    eigenvalues of 'Jmo'.
% 5. Constructs the state-space matrices ('A', 'B') for the combined SSMO 
%    system.
%
% Methods:
% --------
% - 'ssmo': Constructor to initialize the 'ssmo' object with system and 
%   observer models.
%
% Implementation Steps:
% ---------------------
% 1. The 'sys', 'Jmo', and 'Pmo' inputs are assigned to corresponding 
%    properties of the 'ssmo' object.
% 2. Observer gain matrices ('LJ', 'LP') are padded using the 'pad3DL' 
%    function to align them with the full output space.
% 3. The 'systemPSetup' function is used to derive 'AJp', 'BJp' (for Jmo) 
%    and 'APp', 'BPp' (for Pmo), representing the system matrices for the 
%    primary and secondary observers, respectively.
% 4. Transformation matrices are derived by solving for polynomial 
%    coefficients ('q') from the eigenvalues of 'Jmo' and passing them 
%    through the 'SSMOTransformationSetup' function for both 'Jmo' and 
%    'Pmo'.
% 5. The final state-space matrices 'A' and 'B' for the SSMO system are 
%    constructed using 'ssmoSysSetup'.
%
% Notes:
% ------
% - The 'pad3DL', 'systemPSetup', 'rootsToCoefficients', 
%   'SSMOTransformationSetup', and 'ssmoSysSetup' functions must be 
%   available in the same workspace or path for this class to function 
%   properly.
% - The transformation matrices ('T') and system matrices ('A', 'B') are 
%   stored as part of the 'ssmo' object for use in further simulations or 
%   analysis.
%
% Example Usage:
% --------------
% % Define the system model
% sys = msd()
%
% % Define the primary and secondary observers
% Jmo = mo();
% Pmo = mo();
%
% % Create an instance of the SSMO class
% ssmoObj = ssmo(sys, Jmo, Pmo);
%
% % Access the state-space matrices
% A = ssmoObj.A;
% B = ssmoObj.B;
%
% See also:
% ---------
% pad3DL, systemPSetup, rootsToCoefficients, SSMOTransformationSetup, ssmoSysSetup


    properties
        Name
        sys
        numOutputs
        T
        A
        B
        COutputs
        Attack
        Jmo
        Pmo
    end

    methods
        function obj = ssmo(sys,Jmo,Pmo)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            % Define Ap and Bp for each observer
            obj.sys = sys;
            obj.Name = 'SSMO';
            obj.Attack = Jmo.Attack;
            obj.numOutputs = Jmo.numOutputs;
            obj.COutputs = Jmo.COutputs;
            obj.Jmo = Jmo;
            obj.Pmo = Pmo;

            % Pad the L matrices so that they are compatible with the full output
            LJpadded = pad3DL(Jmo);
            LPpadded = pad3DL(Pmo);

            % Define Ap and Bp for each observer
            [AJp,BJp] = systemPSetup(Jmo,LJpadded);
            [APp,BPp] = systemPSetup(Pmo,LPpadded);

            % Derive the transfomration matrix for each observer
            q = rootsToCoefficients(Jmo.eigenvalues);
            q = q(2:end);
            [TJ] = SSMOTransformationSetup(AJp,BJp,q,Jmo);
            [TP] = SSMOTransformationSetup(APp,BPp,q,Pmo);
            obj.T = cat(3,TJ,TP);

            % Define THE A and B matrices
            [obj.A,obj.B] = ssmoSysSetup(q,obj);


        end

    end
end