clearvars; close all;
fprintf('\n')
% Number of outputs
numOutputs = 3;
fprintf('The number of outputs is %3.0f: \n',numOutputs)

% Set solver: lsim or ode45
solver = 'lsim';

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
[sys,sysName] = dampedSpringMassSetup(0.2,5,0.5);
% [sys,sysName] = doubleDampedSpringMassSetup(0.3,0.2,6,7,0.5,0.5);
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
CMOdict('sizeJObservers')       = sizeJObservers;
CMOdict('numJObservers')        = numJObservers;
CMOdict('sizePObservers')       = sizePObservers;
CMOdict('numPObservers')        = numPObservers;
CMOdict('numOriginalStates')    = numOriginalStates;
CMOdict('numOriginalInputs')    = numOriginalInputs;
CMOdict('numOriginalOutputs')   = numOriginalOutputs;


% Define time series for simulation
t = 0:0.01:5;
fprintf('\n Defining system with (%4.0f) J-sized (%3.0f) observers. \n',CMOdict('numJObservers'),CMOdict('sizeJObservers'))
[cmoJSystem,solJ,solJIndices,CMOdict] = cmoSolution(sys, ...
                                        t, ...
                                        solver,...
                                        'J', ...
                                        CMOdict);
fprintf('\n Defining system with (%4.0f) P-sized (%3.0f) observers. \n',numPObservers,sizePObservers)
[cmoPSystem,solP,solPIndices,CMOdict] = cmoSolution(sys, ...
                                        t, ...
                                        solver,...
                                        'P', ...
                                        CMOdict);


fprintf('\n Extracting estimator solution.\n')
% Extract 'chosen' estimate from estimates throughout the simulation
[solEst, cmoError] = selectEstimatorSolution(solJ,solP,solJIndices,solPIndices,CMOdict);

fprintf('\n System solved.\n')
%% Plots
close all;
% decide on what size grid should be used based on number of states in
% system
numberOfColumns = ceil(sqrt(numOriginalStates));
numberOfRows = ceil(numOriginalStates/numberOfColumns);

fig = figure();
sgtitle({[char(sysName),' observed by a multi-observer with ', num2str(numOutputs),' outputs.'],[ 'So M=',num2str(M),',J=',num2str(sizeJObservers),' and P=',num2str(sizePObservers)]});
% Create entities to use in legend
solLineWidth = 2; solColor = 'black';
estJLineStyle = '--'; estJColor = 'red';
estPLineStyle = '--'; estPColor = 'blue';
 
% create tiled plot
for l = 1:1:numOriginalStates
    % select subplot to edit
    subplot(numberOfRows,numberOfColumns,l);
    
    % rows of sysJ to be plotted are l, l + j*n,...,l + j*(N+1)
    for j = 0:1:numJObservers
        rowIdToPlot = l + j*(numOriginalOutputs);
        rowToPlot = solJ(rowIdToPlot,:);
        p = plot(t,rowToPlot);

        hold on
        if j == 0
            legend('AutoUpdate','on')
            p.LineWidth = solLineWidth;
            p.Color = solColor;
        elseif j > 0
            legend('AutoUpdate','off')
            p.LineStyle = estJLineStyle;
            p.Color = estJColor;
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
            legend('AutoUpdate','on')
            p.LineWidth = 2;
            p.Color = 'black';
        elseif j > 0
            legend('AutoUpdate','off')
            p.LineStyle = '--';
            p.Color = 'blue';
        end
        hold on
    end

    % Plot the selected estimate
    legend('AutoUpdate','on')
    plot(t,solEst(l,:),LineStyle="-",Color='cyan',LineWidth=2);
    plot(t,cmoError(l,:),LineStyle="-",Color='#EDB120',LineWidth=1);
%     legend({'True response','J-sized estimators','P-sized estimators','Multi-observer'})
    hold on;
    title(strcat('x',num2str(l)))
    grid on;

end

set(gcf, 'Position', 0.9*get(0, 'Screensize'));

