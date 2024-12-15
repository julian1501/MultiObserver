classdef lssmo
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Name
        sys
        numOutputs
        Rq
        A
        B
        COutputs
        Attack

    end

    methods
        function obj = lssmo(sys,Jmo,Pmo)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            % Define Ap and Bp for each observer
            obj.sys = sys;
            obj.Name = 'Lean SSMO';
            obj.Attack = Jmo.Attack;
            obj.numOutputs = Jmo.numOutputs;
            obj.COutputs = Jmo.COutputs;

            % Derive the transfomration matrix for each observer
            q = rootsToCoefficients(Jmo.eigenvalues);
            q = q(2:end);

            % Define THE A and B matrices
            [obj.A,obj.B] = ssmoSysSetup(q,obj);
            
            % Find Static Rq
            I = eye(mo.numOutputs + mo.sys.NLsize);
            RqValues = zeros(mo.nx);
        
            for i = 1:1:mo.nx
                newRow = [zeros(1,i-1) 1 q(1:end-1)];
                RqValues(i,:) = newRow(1:mo.nx);
            end
        
            % multiply all individual eigenvalues by the appropriatly sized
            % identity matrix
            obj.Rq = kron(RqValues,I);
        
        end

    end
end