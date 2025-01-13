classdef mo
% mo Class
%
% The 'mo' class defines a multi-observer system that observes a given 
% dynamic system. It contains the configuration and initialization of 
% observers and includes attack handling, observer matrices (A and L), as 
% well as the setup for different system outputs.
%
% Documentation written with help of ChatGPT.
%
% Properties:
% -----------
% - 'sys': The system that the multi-observer observes. It includes system 
%   matrices like 'A', 'B', and 'C'.
% - 'nx': The number of system states, which corresponds to the size of the
%   'A' matrix.
% - 'ny': The number of outputs of the system (e.g., number of sensors).
% - 'nu': The number of inputs to the system.
% - 'numOutputs': The total number of outputs for the whole system.
% - 'numObservers': The number of J-observers used in the multi-observer setup.
% - 'numOutputsObservers': The number of outputs for each J-observer.
% - 'Ci': The outputs associated with each J-observer.
% - 'CiIndices': The indices of the outputs for each J-observer.
% - 'attack3d': A 3D matrix storing attack values for each J-observer.
% - 'Ai': A cell array that stores all the A matrices for each J-observer.
% - 'Li': A cell array that stores all the L matrices for each J-observer.
% - 'eigenvalues': A vector storing system eigenvalues.
% - 'COutputs': The matrix of all outputs of the system.
% - 'Attack': The attack object, which contains information about the 
%   attacks on the system.
%
% Methods:
% --------
% - 'mo(sys, Attack, numOutputs, numOutputsObserver)': Constructor to 
%   initialize an instance of the 'mo' class.
%   - 'sys': The system being observed. This includes matrices such as 'A',
%     'B', 'C', etc.
%   - 'Attack': The attack object, which specifies the details of attacks.
%   - 'numOutputs': The total number of outputs for the system.
%   - 'numOutputsObserver': The number of outputs for each observer.
%
% Constructor Description:
% ------------------------
% The constructor initializes the 'mo' class object by setting various 
% properties including system matrices, the number of outputs and observers,
% attack configurations, and observer matrices. It performs checks to ensure
% that the number of system outputs is greater than twice the number of 
% attacked outputs and initializes the necessary matrices and configurations
% for both system and observers.
%
% Initialization Steps:
% ---------------------
% - The constructor checks the system's number of outputs and ensures the 
%   number of attacked outputs is valid.
% - It computes the 'Ci' matrix (outputs associated with each observer) and
%   the 'CiIndices' (indices for each observer).
% - A 3D matrix 'attack3d' is created to store the attack values for each 
%   J-observer.
% - It sets default eigenvalue options for the system and assigns them to 
%   the system.
% - The constructor calls a function 'defineObservers()' to initialize the 
%   observer matrices 'Ai' and 'Li'.
%
% Example:
% --------
% To create an instance of the 'mo' class, you would use:
% sys = msd();  % A predefined system object
% Attack = attack();  % A predefined attack object
% numOutputs = 6;
% numOutputsObserver = 3;
% moObj = mo(sys, Attack, numOutputs, numOutputsObserver);
% This would initialize an 'mo' object with the provided system and attack 
% details.
%
% Notes:
% ------
% - The constructor automatically handles system and observer initialization.
% - The class uses predefined eigenvalue options, which can be modified in 
%   the future for different systems.
% - The 'COutputs', 'Ci', and 'attack3d' matrices are computed during 
%   initialization using helper functions ('CNSetup', 'CsetSetup').
%
% See also:
% ---------
% CNSetup, CsetSetup, defineObservers, msd, attack


    properties
        % System that the multi-observer observes
        sys
        % Number of system states (size of A matrix)
        nx
        % Number of different possible outputs
        ny
        % Number of inputs
        nu
        % Number of outputs of the whole system (e.g. number of sensors)
        numOutputs
        % Number of J-observers
        numObservers
        % Number of outputs of each J-observer (often
        % numOuptus-numAttackedOutputs)
        numOutputsObservers
        % Outputs of each J-observer
        Ci
        % Indices of each J-observer
        CiIndices
        % 3D matrix that stores all the attack values for J observers
        attack3d
        % All A matrices for the J observer
        Ai
        % All L matrices for the J observer
        Li
        % system eigenvalues
        eigenvalues
        % all outputs of the system
        COutputs
    
        Attack
    end

    methods
        function obj = mo(sys,Attack,numOutputs,numOutputsObserver)
            %UNTITLED6 Construct an instance of this class
            %   Detailed explanation goes here
            obj.sys = sys;
            obj.nx = size(sys.A,1);
            obj.ny = size(sys.C,1);
            obj.nu = size(sys.B,2);
            obj.Attack = Attack;
            % Check whether numoutputs > 2*numAttackedOutputs
            if ~ (numOutputs > 2* Attack.numAttacks)
               error('The number of outputs is not larger then twice the number of attacked outputs %3.0f <= %3.0f',numOutputs,numAttackedOutputs); 
            end
            obj.numOutputs = numOutputs;
            obj.numOutputsObservers = numOutputsObserver;
            obj.numObservers = nchoosek(numOutputs,numOutputsObserver);
    
            obj.COutputs = CNSetup(obj);
            [Ci,CiIndices,attack3D] = CsetSetup(obj.COutputs,Attack,obj);

            obj.numObservers = size(Ci,3);
            obj.numOutputsObservers = size(Ci,1);
    
            obj.Ci = Ci;
            obj.CiIndices = CiIndices;
            obj.attack3d = attack3D;
            
            eigenvalueOptions = [-3 -4 -5 -6 -7 -8 -9 -10 -11 -12 -13 -14];
            obj.eigenvalues = eigenvalueOptions(1:obj.nx);
        
            [Ai,Li] = defineObservers(sys.A,Ci,obj.eigenvalues,obj);
    
            obj.Ai = Ai;
            obj.Li = Li;
    
        end
    
    end

end