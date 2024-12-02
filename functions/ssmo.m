classdef ssmo
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        sys
        numOutputs
        T
        A
        B
        COutputs
    end

    methods
        function obj = ssmo(sys,Jmo,Pmo)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            % Define Ap and Bp for each observer
            obj.sys = sys;
            obj.numOutputs = Jmo.numOutputs;
            obj.COutputs = Jmo.COutputs;

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