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
% See also: cmo3d,  ssmo

    properties
        Name
        sys
        numObservers
        numOutputs
        Attack % class
        A
        F
        attack
        B
        u
        x0
        PSubsetOfJIndices
    end

    methods
        function obj = cmo2d(sys,Jmo,Pmo)
            obj.Name = "2D-CMO";
            obj.sys = sys;
            obj.numObservers = Jmo.numObservers + Pmo.numObservers;
            obj.numOutputs = Jmo.numOutputs;
            obj.Attack = Jmo.Attack;
            
            [ApLCJ,LCJ] = ApLCSetup(Jmo);
            [ApLCP,LCP] = ApLCSetup(Pmo);
            
            % A matrix subblocks
            A13 = zeros(Jmo.numObservers*sys.nx,Pmo.numObservers*sys.nx);
            A22 = A13';

            % reshape all matrices to 2d format
            ApLCJ = diag3d(ApLCJ);
            LCJ = flatten(LCJ);
            ApLCP = diag3d(ApLCP);
            LCP = flatten(LCP);

            obj.A = [-LCJ, ApLCJ,   A13;
                     -LCP,   A22, ApLCP];

            B = repmat(sys.B,Jmo.numObservers+Pmo.numObservers,1);
            LJ = diag3d(Jmo.Li);
            LP = diag3d(Pmo.Li);
            L12 = zeros(size(LJ,1),size(LP,2));
            L21 = zeros(size(LP,1),size(LJ,2));
            L = [-LJ,L12; L21,-LP];
            obj.F = [B L];

            obj.attack = cat(1,reshape(Jmo.attack3d,[],1,1),reshape(Pmo.attack3d,[],1,1));
            
        end

    end
end