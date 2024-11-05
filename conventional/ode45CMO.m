clearvars; close all;
fprintf('\n')
% Number of outputs
numOutputs = 5;
fprintf('The number of outputs is %3.0f: \n',numOutputs)

% M: maximum number of corrupted outputs
M = floor((numOutputs-1)/2);
if ~ M > 0
    error('M is 0')
elseif ~ numOutputs > 2*M
    error('N is not larger then 2M.')
end
fprintf('The maximum allowable number of compromised outputs %3.0f: \n',M)
numOutputsJObservers = numOutputs-M;
fprintf('The size of each J observer is: %3.0f \n',numOutputsJObservers)
numOutputsPObservers = numOutputs-2*M;
fprintf('The size of each P observer is: %3.0f \n',numOutputsPObservers)
numJObservers = nchoosek(numOutputs,numOutputsJObservers);
fprintf('The number of J observers is: %3.0f \n',numJObservers)
numPObservers = nchoosek(numOutputs,numOutputsPObservers);
fprintf('The number of P observers is: %3.0f \n',numPObservers)

% Noiseless system definition
% sysNum implies number of mass spring dampers in series
sysNum = 1;
if sysNum == 1
    [sys,sysName] = dampedSpringMassSetup(0.2,5,0.5);
elseif sysNum == 2
    [sys,sysName] = doubleDampedSpringMassSetup(0.3,0.2,6,7,0.5,0.5);
end
sysA = sys.A;
numOriginalStates  = size(sysA,1);
sysB = sys.B;
numOriginalInputs  = size(sysB,2);
sysC = sys.C;
numOriginalOutputs = size(sysC,1);
sysD = sys.D;
if sysD ~= 0
    error('Implementation for systems with D still needs work.')
end


% define a dictionary that stores all info
CMOdict = dictionary();
CMOdict('numOutputs')           = numOutputs;
CMOdict('M')                    = M;
CMOdict('numOutputsJObservers') = numOutputsJObservers;
CMOdict('numJObservers')        = numJObservers;
CMOdict('numOutputsPObservers') = numOutputsPObservers;
CMOdict('numPObservers')        = numPObservers;
CMOdict('numOriginalStates')    = numOriginalStates;
CMOdict('numOriginalInputs')    = numOriginalInputs;
CMOdict('numOriginalOutputs')   = numOriginalOutputs;


COutputs = CNSetup(sys,numOutputs);
[CJ,CJIndices] = CsetSetup(COutputs,'J',CMOdict);
[CP,CPIndices] = CsetSetup(COutputs,'P',CMOdict);

% find which p observers are subsets of each j observer
[numOfPsubsetsInJ, PsubsetOfJIndices] = findIndices(CJIndices,CPIndices,CMOdict);
CMOdict('numOfPsubsetsInJ') = numOfPsubsetsInJ;

eigenvalueOptions = [-1 -2 -3 -4 -5 -6 -7 -8];
[AStarJ,LJ] = systemJSetup(sysA,sysB,CJ,eigenvalueOptions,'J',CMOdict);
[AStarP,LP] = systemJSetup(sysA,sysB,CP,eigenvalueOptions,'P',CMOdict);
[ApLCJ,LCJ] = systemStarSetup(AStarJ,LJ,CJ,'J',CMOdict);
[ApLCP,LCP] = systemStarSetup(AStarP,LP,CP,'P',CMOdict);

% Astar matrix subblocks
A21 = zeros(numOriginalStates,numJObservers*numOriginalStates);
A31 = zeros(numOriginalStates,numPObservers*numOriginalStates);
A23 = zeros(numJObservers*numOriginalStates,numPObservers*numOriginalStates);
A32 = A23';


ATilde = [sysA,   A21,   A31;
         -LCJ, ApLCJ,   A23;
         -LCP,   A32, ApLCP];

Bstar = repmat(sysB,1+numJObservers+numPObservers,1);

CMOdict('numCMOStates') = size(ATilde,1);

% Generate attack signals
[setA, setB] = selectAB(CMOdict);
E = ESetup(Bstar,LJ,LP,CMOdict);
eta = etaSetup(setA,CJIndices,CPIndices,0,0,CMOdict);

clear AStarJ BTildeJ CTildeJ DTildeJ LJ
clear AStarP BTildeP CTildeP DTildeP LP
clear A21 A31 A23 A32 ApLCJ ApLCP LCJ LCP




% Initial condition is the first n elements of x0Options, xhat initial
% conditions are always 0
x0 = zeros((numJObservers+numPObservers+1)*numOriginalStates ,1);
x0Options = [0.3;-0.1;-0.2;0.15;0.18;0.1;-0.25;0.2];
x0(1:numOriginalStates,1) = x0Options(1:numOriginalStates,1);


% solve system
tmin = 0; tmax = 5;
tspan = [tmin tmax];
[t,x] = ode45(@(t,x) ssCMOodeFunSetup(t,x,eta,ATilde,E,PsubsetOfJIndices,CMOdict),tspan,x0);
t = t';
x = x';

% find estimate after the fact, the estimate is also found at each timestep
% within the ssODEfunSetup for feedback purposes
steps = size(x,2);
[estimate, whichJobserver] = selectBestEstimate(x,steps,PsubsetOfJIndices,CMOdict);
err = x(1:numOriginalStates,:) - estimate;

MOplot(t,x,err,estimate,sysName,CMOdict);

