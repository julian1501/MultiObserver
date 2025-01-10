clearvars; close all;

% initialize bools indicating user input (dialog) and if the results should
% be plotted (plot)
dialog = true; Plot = true;
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
attackedOutputs = str2num(inputs{4});
if lower(inputs{5}) == 'max'
    numOutputsPObservers = numOutputs-2*numAttackedOutputs;
else
    numOutputsPObservers = str2num(inputs{5});
end
eigenvalueOptions = str2num(inputs{6});
tspan = str2num(inputs{7});
x0Options = str2num(inputs{8})';
whichMO = str2num(inputs{9});
linear = str2num(inputs{10});
stddev = str2num(inputs{11});


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

% check if the system is stable
if ~isMatrixStable(sys.A)
    warning('The system is unstable')
end
if sys.D ~= 0
    error('Implementation for systems with D still needs work.')
end

% check if there is no nonlinearity in the 2D CMO
if ~linear && whichMO(1) == 1
    error('The 2D CMO does not support nonlinear systems.')
end

% setup the attack and noise
Attack = attack(numOutputs,numAttackedOutputs,attackedOutputs);
Noise = noise(numOutputs,tspan,stddev);

% setup the J and P observers
Pmo = mo(sys,Attack,numOutputs,numOutputsPObservers);
Jmo = mo(sys,Attack,numOutputs,numOutputsJObservers);

% find which P observers are subobservers of J
sys.COutputs = Jmo.COutputs;
[numOfPsubsetsInJ,PsubsetOfJIndices,whichJuseP] = findIndices(Jmo,Pmo);

% Setup the different type of multi-observers
CMO2D = 0; CMO3D = 0; SSMO = 0;
if whichMO(1) == 1
    CMO2D = cmo2d(sys,Jmo,Pmo);
end
if whichMO(2) == 1
    CMO3D = cmo3d(sys,Jmo,Pmo);
end
if whichMO(3) == 1
    SSMO  =  ssmo(sys,Jmo,Pmo);
end


[x0, xIds] = x0setup(x0Options,whichMO,sys,Jmo,Pmo);


% create waitbar
wb = waitbar(0,'Solver is currently at time: 0','Name','Solving the ODE');


[t,x] = ode45(@(t,x) multiObserverODE(wb,tspan(2),sys,t,x,Attack,CMO2D,CMO3D,SSMO,whichMO,Noise,Jmo,Pmo,xIds),tspan,x0);
t = t';
x = x';

close(wb)

state = x(1:sys.nx,:);
if whichMO(1) == 1
    CMO2Dest = x(xIds.xcmo2dStart:xIds.xcmo2dEnd,:);
    % create waitbar
    wb = waitbar(0,'Selection is currently at time: 0','Name','Selecting best estimates 2D-CMO');
    CMO2DbestEst = sbeCPU([state; CMO2Dest],size(t,2),PsubsetOfJIndices,numOfPsubsetsInJ,Jmo,Pmo,sys,wb);
    CMO2Derr = state - CMO2DbestEst;
    close(wb)
end

if whichMO(2) == 1
    CMO3Dest = x(xIds.xcmo3dStart:xIds.xcmo3dEnd,:);
    % create waitbar
    wb = waitbar(0,'Selection is currently at time: 0','Name','Selecting best estimates 3D-CMO');
    CMO3DbestEst = sbeCPU([state; CMO3Dest],size(t,2),PsubsetOfJIndices,numOfPsubsetsInJ,Jmo,Pmo,sys,wb);
    CMO3Derr = state - CMO3DbestEst;
    close(wb)
end

if whichMO(3) == 1
    SSMOz = x(xIds.xssmoStart:xIds.xssmoEnd,:);
    SSMOest = flatten(pagemtimes(SSMO.T,SSMOz));
    % create waitbar
    wb = waitbar(0,'Selection is currently at time: 0','Name','Selecting best estimates SSMO');
    SSMObestEst = sbeCPU([state; SSMOest],size(t,2),PsubsetOfJIndices,numOfPsubsetsInJ,Jmo,Pmo,sys,wb);
    SSMOerr = state - SSMObestEst;
    close(wb)
end

% calculate difference
if sum(whichMO) > 1
    if whichMO(1) + whichMO(2) == 2
        diff = sqrt((CMO2Dest - CMO3Dest).^2);
    elseif whichMO(1) + whichMO(3) == 2
        diff = sqrt((CMO2Dest - SSMOest).^2);
    elseif whichMO(2) + whichMO(3) == 2
        diff = sqrt((CMO3Dest - SSMOest).^2);
    elseif sum(whichMO) == 3
        ... % Standard deviation?
        diff = 0;
    end
    sco = max(max(diff));
    disp(sco)
    if sco < 1e-3
        disp('Tolerance within numerical tolerance.')
    else
        disp('The solutions are not similar.')
    end
end


%% 2D CMO plot
if Plot && whichMO(1) == 1
      MOplot(t,[state; CMO2Dest],CMO2Derr,CMO2DbestEst,sys,CMO2D,Jmo,Pmo);
end
%% 3D CMO plot
if Plot && whichMO(2) == 1
      MOplot(t,[state; CMO3Dest],CMO3Derr,CMO3DbestEst,sys,CMO3D,Jmo,Pmo);
end
%% SSMO plot
if Plot && whichMO(3) == 1
      MOplot(t,[state; SSMOest],SSMOerr,SSMObestEst,sys,SSMO,Jmo,Pmo);
end

