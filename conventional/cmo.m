clearvars; close all;
fprintf('\n')
% N: number of outputs
N = 3;
fprintf('The number of outputs is %3.0f: \n',N)
% M: maximum number of corrupted outputs
M = floor((N-1)/2);
if ~ M > 0
    error('M is 0')
elseif ~ N > 2*M
    error('N is not larger then 2M.')
end
fprintf('The maximum allowable number of compromised outputs %3.0f: \n',M)
sizeJObservers = N-M;
fprintf('The size of each J observer is: %3.0f \n',sizeJObservers)
sizePObservers = N-2*M;
fprintf('The size of each P observer is: %3.0f \n',sizePObservers)
numObservers = nchoosek(N,sizeJObservers);
fprintf('The number of observers is: %3.0f \n',numObservers)


% Noiseless system definition
sys = dampedSpringMassSetup(0.2,5,0.5);
% sys = doubleDampedSpringMassSetup(0.3,0.2,6,7,0.5,0.5);
sysA = sys.A;
numOriginalStates  = size(sysA,1);
sysB = sys.B;
numOriginalInputs  = size(sysB,2);
sysC = sys.C;
numOriginalOutputs = size(sysC,1);

% Create a multi observer out of the system 'sys'
cmoSystem = subSetCMOSetup(sys,sizeJObservers,N);
Astar = cmoSystem.A;
Bstar = cmoSystem.B;
Cstar = cmoSystem.C;
numCMOStates = size(Astar,1);
numCMOInputs = size(Bstar,2);
numCMOOutputs = size(Cstar,1);

% simulate system
t = 0:0.01:15;
u = zeros(numOriginalInputs,size(t,2));
eta = etaSetup(u,numObservers,numOriginalStates,sizeJObservers,0.01,0);
% Initial condition is the first n elements of x0Options, xhat initial
% conditions are always 0
x0 = zeros(numCMOStates,1);
x0Options = [0.3;-0.1;-0.2;0.15;0.18;0.1;-0.25;0.2];
x0(1:numOriginalOutputs,1) = x0Options(1:numOriginalOutputs,1);

sol = lsim(cmoSystem,eta,t,x0)';

% Extract 'chosen' estimate from estimates throughout the simulation

%% Plots
close all;
% decide on what size grid should be used based on number of states in
% system
numberOfColumns = ceil(sqrt(numOriginalStates));
numberOfRows = ceil(numOriginalStates/numberOfColumns);

% create tiled plot
for l = 1:1:numOriginalStates
    % select subplot to edit
    fig = subplot(numberOfRows,numberOfColumns,l);
    % rows to be plotted are l, l + j*n,...,l + j*(N+1)
    for j = 0:1:numObservers
        rowIdToPlot = l + j*(numOriginalOutputs*sizeJObservers);
        rowToPlot = sol(rowIdToPlot,:);
        p = plot(t,rowToPlot);
        hold on
        if j == 0
            p.LineWidth = 2;
        elseif j > 0
            p.LineStyle = '--';
        end
        hold on
    end
    title(strcat('x',num2str(l)))

end

set(gcf, 'Position', 0.9*get(0, 'Screensize'));

