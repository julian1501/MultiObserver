clearvars; close all;
fprintf(['\n' repmat('-',1,100) '\n'])
inputs = inputDiaglog(true);

sysNum = str2num(inputs{1});
numOutputs = str2num(inputs{2});
if lower(inputs{3}) == 'max'
    numAttackedOutputs = floor((numOutputs-1)/2);
else
    numAttackedOutputs = str2num(inputs{3});
end
if lower(inputs{3}) == 'max'
    numOutputsPObservers = numOutputs-2*numAttackedOutputs;
else
    numOutputsPObservers = str2num(inputs{3});
end
eigenvalueOptions = str2num(inputs{5});
tspan = str2num(inputs{6});
x0Options = str2num(inputs{7})';

%% CALCULATIONS
fprintf('The number of outputs is %3.0f: \n',numOutputs)

% M: maximum number of corrupted outputs
fprintf('The maximum allowable number of compromised outputs %3.0f: \n',numAttackedOutputs)
numOutputsJObservers = numOutputs-numAttackedOutputs;
fprintf('The size of each J observer is: %3.0f \n',numOutputsJObservers)
fprintf('The size of each P observer is: %3.0f \n',numOutputsPObservers)
numJObservers = nchoosek(numOutputs,numOutputsJObservers);
fprintf('The number of J observers is: %3.0f \n',numJObservers)
numPObservers = nchoosek(numOutputs,numOutputsPObservers);
fprintf('The number of P observers is: %3.0f \n',numPObservers)

% Noiseless system definition
[sys,sysName] = xDampedSpringMassSetup(sysNum,[0.3 0.3 0.3 0.3 0.3 0.3],[5 5 5 5 5 5 ],[0.5 0.6 0.7 0.8 0.2 0.65]);

sysA = sys.A;
numOriginalStates  = size(sysA,1);
sysB = sys.B;
numOriginalInputs  = size(sysB,2);
sysC = sys.C;
numOriginalOutputs = size(sysC,1);
sysD = sys.D;
if ~isMatrixStable(sysA)
    warning('The system is unstable',sysName)
end
if sysD ~= 0
    error('Implementation for systems with D still needs work.')
end


% define a dictionary that stores all info
CMOstruct.numOutputs              = numOutputs;
CMOstruct.numAttackedOutputs      = numAttackedOutputs;
CMOstruct.numOutputsJObservers    = numOutputsJObservers;
CMOstruct.numJObservers           = numJObservers;
CMOstruct.numOutputsPObservers    = numOutputsPObservers;
CMOstruct.numPObservers           = numPObservers;
CMOstruct.numOriginalStates       = numOriginalStates;
CMOstruct.numOriginalInputs       = numOriginalInputs;
CMOstruct.numOriginalOutputs      = numOriginalOutputs;

% Setup C matrices
COutputs = CNSetup(sys,numOutputs);
attack = attackSetup(CMOstruct);
[CJ,CJIndices] = CsetSetup(COutputs,attack,'J',CMOstruct);
[CP,CPIndices] = CsetSetup(COutputs,attack,'P',CMOstruct);

% find which p observers are subsets of each j observer
[numOfPsubsetsInJ, PsubsetOfJIndices] = findIndices(CJIndices,CPIndices,CMOstruct);
CMOstruct.numOfPsubsetsInJ = numOfPsubsetsInJ;

[AStarJ,LJ] = systemJSetup(sysA,CJ,eigenvalueOptions,'J',CMOstruct);
[AStarP,LP] = systemJSetup(sysA,CP,eigenvalueOptions,'P',CMOstruct);
[ApLCJ,LCJ] = systemStarSetup(AStarJ,LJ,CJ,'J',CMOstruct);
[ApLCP,LCP] = systemStarSetup(AStarP,LP,CP,'P',CMOstruct);

% Astar matrix subblocks
A21 = zeros(numOriginalStates,numJObservers*numOriginalStates);
A31 = zeros(numOriginalStates,numPObservers*numOriginalStates);
A23 = zeros(numJObservers*numOriginalStates,numPObservers*numOriginalStates);
A32 = A23';


ATilde = [sysA,   A21,   A31;
          -LCJ, ApLCJ,   A23;
          -LCP,   A32, ApLCP];

Bstar = repmat(sysB,1+numJObservers+numPObservers,1);

CMOstruct.numCMOStates = size(ATilde,1);

% Generate attack signals
[setA, setB] = selectAB(CMOstruct);
E = ESetup(Bstar,LJ,LP,CMOstruct);
eta = etaSetup(setA,CJIndices,CPIndices,1,CMOstruct);

% Initial condition is the first n elements of x0Options, xhat initial
% conditions are always 0
if size(x0Options,1) < numOriginalStates
    error('There are more states than initial conditions.')
end
x0 = zeros((numJObservers+numPObservers+1)*numOriginalStates ,1);
x0(1:numOriginalStates,1) = x0Options(1:numOriginalStates,1);


% solve system
[t,x] = ode45(@(t,x) ssCMOodeFunSetup(t,x,eta,ATilde,E,PsubsetOfJIndices,CMOstruct),tspan,x0);
t = t';
x = x';

% find estimate after the fact, the estimate is also found at each timestep
% within the ssODEfunSetup for feedback purposes
steps = size(x,2);
[estimate, whichJobserver] = selectBestEstimate(x,steps,PsubsetOfJIndices,CMOstruct);
err = x(1:numOriginalStates,:) - estimate;
fprintf('The error at the final time step is: %2.20f \n',err(:,end))

MOplot(t,x,err,estimate,sysName,CMOstruct);

