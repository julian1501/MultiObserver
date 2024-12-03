classdef cmo2d
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        sys
        numObservers
        A
        E
        attack
        B
        u
        x0
        PSubsetOfJIndices
    end

    methods
        function obj = cmo2d(sys,Jmo,Pmo)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.sys = sys;
            obj.numObservers = Jmo.numObservers + Pmo.numObservers;
            
            [ApLCJ,LCJ] = systemStarSetup(AStarJ,LJ,CJ,'J',CMOstruct);
            [ApLCP,LCP] = systemStarSetup(AStarP,LP,CP,'P',CMOstruct);
            
            % Astar matrix subblocks
            A21 = zeros(numOriginalStates,numJObservers*numOriginalStates);
            A31 = zeros(numOriginalStates,numPObservers*numOriginalStates);
            A23 = zeros(numJObservers*numOriginalStates,numPObservers*numOriginalStates);
            A32 = A23';

            obj.A = [sysA,   A21,   A31;
                     -LCJ, ApLCJ,   A23;
                     -LCP,   A32, ApLCP];

            B = repmat(sysB,1+numJObservers+numPObservers,1);
            obj.E = ESetup(B,Jmo.Li,Pmo.Li,obj);
            
        end

    end
end