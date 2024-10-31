function ssPlot(sysName,t,x,CMOdict)

numOriginalStates = CMOdict('numOriginalStates');
numOutputs = CMOdict('numOutputs');
numOutputsJObservers = CMOdict('numOutputsJObservers');
% Plots
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
end