function CMOPlot(sol,t,numOriginalStates, numObservers, numOriginalOutputs, sizeJObservers)
    % Plots all observers and solution to of a CMO
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
end