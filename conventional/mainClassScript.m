clearvars; close all;

% initialize bools indicating user input (dialog) and if the results should
% be plotted (plot)
dialog = true; plot = true;
fprintf(['\n' repmat('-',1,100) '\n'])
inputs = inputDialog(dialog);

% extract input string values into number type variables
sysNum = str2num(inputs{1});
numOutputs = str2num(inputs{2});
if lower(inputs{3}) == 'max'
    numAttackedOutputs = floor((numOutputs-1)/2);
else
    numAttackedOutputs = str2num(inputs{3});
end
if lower(inputs{4}) == 'max'
    numOutputsPObservers = numOutputs-2*numAttackedOutputs;
else
    numOutputsPObservers = str2num(inputs{4});
end
eigenvalueOptions = str2num(inputs{5});
tspan = str2num(inputs{6});
x0Options = str2num(inputs{7})';
whichMO = str2num(inputs{8});
linear = str2num(inputs{9});


%% CALCULATIONS
% display information in the command window
fprintf('The number of outputs is %3.0f: \n',numOutputs)
fprintf('The maximum allowable number of compromised outputs %3.0f: \n',numAttackedOutputs)
numOutputsJObservers = numOutputs-numAttackedOutputs;
fprintf('The size of each J observer is: %3.0f \n',numOutputsJObservers)
fprintf('The size of each P observer is: %3.0f \n',numOutputsPObservers)
numJObservers = nchoosek(numOutputs,numOutputsJObservers);
fprintf('The number of J observers is: %3.0f \n',numJObservers)
numPObservers = nchoosek(numOutputs,numOutputsPObservers);
fprintf('The number of P observers is: %3.0f \n',numPObservers)

% system definition
sys = msd(linear,sysNum,1,15,2.0);

if ~isMatrixStable(sys.A)
    warning('The system is unstable')
end
if sys.D ~= 0
    error('Implementation for systems with D still needs work.')
end

% setup the attack
Attack = attack(numOutputs,numAttackedOutputs);

% setup the J and P observers
Pmo = mo(sys,Attack,numOutputs,numOutputsPObservers);
Jmo = mo(sys,Attack,numOutputs,numOutputsJObservers);

% find which P observers are subobservers of J
sys.COutputs = Jmo.COutputs;
[numOfPsubsetsInJ,PsubsetOfJIndices] = findIndices(Jmo,Pmo);

% Setup the different type of multi-observers
CMO2D = 0; CMO3D = 0; SSMO = 0;
if whichMO(1) == 1
    CMO2D = 0;
end
if whichMO(2) == 1
    CMO3D = cmo3d(sys,Jmo,Pmo);
end
if whichMO(3) == 1
    SSMO  =  ssmo(sys,Jmo,Pmo);
end


x0 = x0setup(x0Options,whichMO,sys,Jmo,Pmo);


[t,x] = ode45(@(t,x) multiObserverODE(sys,t,x,Attack,CMO2D,CMO3D,SSMO,whichMO),tspan,x0);
t = t';
x = x';

state = x(1:sys.nx,:);
CMO3Dest = x(sys.nx+1:end-size(SSMO.A,1),:);
SSMOz = x(end-size(SSMO.A,1)+1:end,:);
SSMOest = flatten(pagemtimes(SSMO.T,SSMOz));

CMO3DbestEst = selectBestEstimate([state; CMO3Dest],size(t,2),PsubsetOfJIndices,numOfPsubsetsInJ,Jmo,Pmo,sys);
CMO3Derr = state - CMO3DbestEst;
SSMObestEst = selectBestEstimate([state; SSMOest],size(t,2),PsubsetOfJIndices,numOfPsubsetsInJ,Jmo,Pmo,sys);
SSMOerr = state - SSMObestEst;
err = 0; bestEst = 0;
% calculate difference
diff = CMO3Dest - SSMOest;
score = max(max(abs(diff)));
disp(score)
if score < 1e-3
    disp('Tolerance within numerical tolerance.')
else
    disp('The solutions are not similar.')
end

if plot && whichMO(1) == 1
      MOplot(t,[state; CMO2Dest],bestEst,sys,CMO2D,Jmo,Pmo);
end
if plot && whichMO(2) == 1
      MOplot(t,[state; CMO3Dest],CMO3Derr,CMO3DbestEst,sys,CMO3D,Jmo,Pmo);
end
if plot && whichMO(3) == 1
      MOplot(t,[state; SSMOest],SSMOerr,SSMObestEst,sys,SSMO,Jmo,Pmo);
end

