classdef mo
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here

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
    end

    methods
        function obj = mo(sys,Attack,numOutputs,numOutputsObserver)
            %UNTITLED6 Construct an instance of this class
            %   Detailed explanation goes here
            obj.sys = sys;
            obj.nx = size(sys.A,1);
            obj.ny = size(sys.C,1);
            obj.nu = size(sys.B,2);
            % Check whether numoutputs > 2*numAttackedOutputs
            if ~ (numOutputs > 2* Attack.numAttacks)
               error('The number of outputs is not larger then twice the number of attacked outputs %3.0f <= %3.0f',numOutputs,numAttackedOutputs); 
            end
            obj.numOutputs = numOutputs;
            obj.numOutputsObservers = numOutputsObserver;
            obj.numObservers = nchoosek(numOutputs,numOutputsObserver);

            obj.COutputs = CNSetup(obj);
            [Ci,CiIndices,attack3D] = CsetSetup(obj.COutputs,Attack,obj);

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