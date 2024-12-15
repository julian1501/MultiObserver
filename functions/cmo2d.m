classdef cmo2d
% cmo2d- creates a 2D conventional multi-observer using a system, the set
% of J-observers and the set of P-observers.
%
% Syntax:  obj = cmo2d(sys,Jmo,Pmo)
%
% Inputs:
%    sys - System model containing:
%        - 'nx': Number of states.
%        - 'A': State transition matrix.
%        - 'COutputs': Output matrix.
%        - 'E': Coupling matrix for nonlinear springs.
%        - 'NLsize': Size of the nonlinear system components.
%        - 'Linear': Logical indicating whether the system is linear.
%    Jmo - mo object for all J-observers
%        - 'sys': (same as input)
%        - 'nx': number of states
%        - 'ny': number of distinct outputs
%        - 'nu': number of inputs
%        - 'numOutputs': number of multi-observer outputs
%        - 'numObservers': number of distinct observers in this mo object
%        - 'numOutputsObservers': number of outputs per observer
%        - 'Ci': (numOutputsObserver,nx,numObservers) sized array
%           containing all Cis on each slice along the third dimension.
%        - 'CiIndices': (numObservers,numOutputsObservers) sized array
%           where each row contains the indices of the outputs used in the
%           observer.
%    Pmo - mo object for all J-observers
%
% Properties:
%    sys - see input
%    numObservers - total number of observers
%    A - shared state matrix for all observers
%    E - shared 'input' matrix for all observers
%    attack - 
%    B
%    u
%    x0
%    PSubsetOfJIndices
%
% Example: 
%    Line 1 of example
%    Line 2 of example
%    Line 3 of example
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: OTHER_FUNCTION_NAME1,  OTHER_FUNCTION_NAME2

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