function MOplot(t,x,err,estimate,sysName,MOdict)
    % This function plots the MO solutions

    % Extract values from MO
    numOriginalStates = MOdict('numOriginalStates');
    numOutputs = MOdict('numOutputs');
    M = MOdict('M');
    numOutputsJObservers = MOdict('numOutputsJObservers');
    numJObservers = MOdict('numJObservers');
    numOutputsPObservers = MOdict('numOutputsPObservers');
    numPObservers = MOdict('numPObservers');
    
    % decide on what size grid should be used based on number of states in
    % system
    numberOfColumns = ceil(sqrt(numOriginalStates));
    numberOfRows = ceil(numOriginalStates/numberOfColumns);
    
    fig = figure();
    sgtitle({[char(sysName),' observed by a multi-observer with ', num2str(numOutputs),' outputs.'],[ 'So M=',num2str(M),',|J|=',num2str(numOutputsJObservers),' and |P|=',num2str(numOutputsPObservers)]});
    
    % cmoEstimate = 
    trueResponse = x(1:numOriginalStates,:);
    JEstimates = x(numOriginalStates+1:numOriginalStates+numJObservers*numOriginalStates,:);
    PEstimates = x(numOriginalStates+numJObservers*numOriginalStates+1:end,:);

    % create tiled plot
    for l = 1:1:numOriginalStates
        % select subplot to edit
        subplot(numberOfRows,numberOfColumns,l);
        
        % plot all p and j estimators
        for k=1:1:numJObservers
            plot(t,JEstimates((k-1)*numOriginalStates+l,:),LineStyle="--",Color='red')
            hold on;
            if k < numPObservers
                plot(t,PEstimates((k-1)*numOriginalStates+l,:),LineStyle="--",Color='blue')
                hold on;
            end
    
        end
    
        % plot system response
        plot(t,trueResponse(l,:),LineWidth=2,Color='black')
        hold on;
        
        % plot the cmo estimate
        plot(t,estimate(l,:),LineWidth=1,Color='cyan')
        hold on;
    
        % plot error
        plot(t,err(l,:),LineWidth=1,Color="#EDB120")
        hold on;
        grid on;
    end
    
    set(gcf, 'Position', 0.7*get(0, 'Screensize'));
    hold off;
end