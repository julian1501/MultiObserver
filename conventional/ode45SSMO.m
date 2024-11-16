clearvars; close all;
fprintf('\n -------------------------------------------------')
inputs = inputDiaglog;

sysNum = str2num(inputs{1});
numOutputs = str2num(inputs{2});
if lower(inputs{3}) == 'max'
    M = floor((numOutputs-1)/2);
else
    M = str2num(inputs{3});
end
eigenvalueOptions = str2num(inputs{4});
tspan = str2num(inputs{5});
x0Options = str2num(inputs{6})';
attackSignal = str2num(inputs{7});

%% Calculations
fprintf('The number of outputs is %3.0f: \n',numOutputs)

% M: maximum number of corrupted outputs
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


