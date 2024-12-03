classdef cmo3d
    %UNTITLED9 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Name
        sys
        numObservers
        numOutputs
        ApLC
        LC
        C
        L
        attack
        B
        E
        u
        x0
        Attack
    end

    methods
        function obj = cmo3d(sys,Jmo,Pmo)
            %UNTITLED9 Construct an instance of this class
            %   Detailed explanation goes here
            obj.sys = sys;
            obj.Name = '3D-CMO';
            obj.Attack = Jmo.Attack;
            obj.numObservers = Jmo.numObservers + Pmo.numObservers;
            obj.numOutputs = Jmo.numOutputs;
            

            [ApLCJ,LCJ] = systemStarSetup3D(Jmo);
            [ApLCP,LCP] = systemStarSetup3D(Pmo);

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
            obj.attack = cat(3,Jmo.attack3d,PAttackPadded);
            obj.B    = repmat(sys.B,1,1,obj.numObservers);
            obj.E    = repmat([0 0; 0 1],1,1,obj.numObservers);
        end

    end

end