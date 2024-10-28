clearvars; close all;
fprintf('\n')
% Number of outputs
numOutputs = 4;
fprintf('The number of outputs is %3.0f: \n',numOutputs)
% M: maximum number of corrupted outputs
M = floor((numOutputs-1)/2);
if ~ M > 0
    error('M is 0')
elseif ~ numOutputs > 2*M
    error('N is not larger then 2M.')
end
fprintf('The maximum allowable number of compromised outputs %3.0f: \n',M)
sizeJObservers = numOutputs-M;
fprintf('The size of each J observer is: %3.0f \n',sizeJObservers)
sizePObservers = numOutputs-2*M;
fprintf('The size of each P observer is: %3.0f \n',sizePObservers)
numJObservers = nchoosek(numOutputs,sizeJObservers);
fprintf('The number of observers is: %3.0f \n',numJObservers)
numPObservers = nchoosek(numOutputs,sizePObservers);
fprintf('The number of observers is: %3.0f \n',numPObservers)


% Noiseless system definition
sys = dampedSpringMassSetup(0.2,5,0.5);
% sys = doubleDampedSpringMassSetup(0.3,0.2,6,7,0.5,0.5);
sysA = sys.A;
numOriginalStates  = size(sysA,1);
sysB = sys.B;
numOriginalInputs  = size(sysB,2);
sysC = sys.C;
numOriginalOutputs = size(sysC,1);
% Combine original States Inputs and Outputs in an array
numOriginalSIO = [numOriginalStates, numOriginalInputs, numOriginalOutputs];


% Define time series for simulation
t = 0:0.01:5;
fprintf('Defining system with (%4.0f) J-sized (%3.0f) observers. \n',numJObservers,sizeJObservers)
[cmoJSystem,solJ,t,numCMOStatesJ,numCMOInputsJ,numCMOOutputsJ] = cmoSolution(sys, ...
                                                                             t, ...
                                                                             numOutputs, ...
                                                                             numJObservers, ...
                                                                             sizeJObservers, ...
                                                                             numOriginalSIO);
fprintf('Defining system with (%4.0f) P-sized (%3.0f) observers. \n',numPObservers,sizePObservers)
[cmoPSystem,solP,t,numCMOStatesP,numCMOInputsP,numCMOOutputsP] = cmoSolution(sys, ...
                                                                             t, ...
                                                                             numOutputs, ...
                                                                             numPObservers, ...
                                                                             sizePObservers, ...
                                                                             numOriginalSIO);


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
    % rows of sysJ to be plotted are l, l + j*n,...,l + j*(N+1)
    for j = 0:1:numJObservers
        rowIdToPlot = l + j*(numOriginalOutputs);
        rowToPlot = solJ(rowIdToPlot,:);
        p = plot(t,rowToPlot);

        hold on
        if j == 0
            p.LineWidth = 2;
            p.Color = 'black';
        elseif j > 0
            p.LineStyle = '--';
            p.Color = 'red';
        end
        hold on
    end

    % rows of sysP to be plotted are l, l + j*n,...,l + j*(N+1)
    for j = 0:1:numPObservers
        rowIdToPlot = l + j*(numOriginalOutputs);
        rowToPlot = solP(rowIdToPlot,:);
        p = plot(t,rowToPlot);

        hold on
        if j == 0
            p.LineWidth = 2;
            p.Color = 'black';
        elseif j > 0
            p.LineStyle = '--';
            p.Color = 'blue';
        end
        hold on
    end
    title(strcat('x',num2str(l)))

end

set(gcf, 'Position', 0.9*get(0, 'Screensize'));

