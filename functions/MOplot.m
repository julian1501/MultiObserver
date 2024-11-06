function MOplot(t,x,err,estimate,sysName,MOdict)
    % MOplot(t,x,err,estimate,sysName,MOdict) plots the solutions of the
    % CMO. It creates a plot for each system state, on each plot the system
    % response, J-observers, P-observers, CMO final estimate and the error
    % into a single plot.
    %
    % Example values for inputs (single state):
    %   - t = 0:0.01:5
    %     x        = [0.10 0.20 0.30 0.40 0.50;
    %                 0.30 0.20 0.10 0.05 0.01;
    %                 0.30 0.40 0.50 0.60 0.70;
    %                 0.20 0.25 0.20 0.15 0.20;
    %                 0.05 0.10 0.15 0.20 0.25]
    %     err      = [0.01 0.02 0.01 0.02 0.03]
    %     estimate = [0.30 0.20 0.50 0.60 0.70]
    %     sysName  = "Example single input system"

    % Find the maximum 

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