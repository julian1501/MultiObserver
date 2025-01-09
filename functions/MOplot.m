function MOplot(t,x,err,estimate,sys,MO,Jmo,Pmo)
% MOplot Function
%
% The 'MOplot' function generates a series of plots to visualize the results 
% of a Composite Multi-Observer (CMO) system. It creates a separate plot for 
% each system state, displaying the system response, J-observers' estimates, 
% P-observers' estimates, the final CMO estimate, and the error for each state 
% over time. The plots are arranged in a grid depending on the number of 
% states in the system.
%
% Documentation written by ChatGPT.
%
% Syntax:
% -------
% MOplot(t, x, err, estimate, sys, MO, Jmo, Pmo)
%
% Inputs:
% -------
% - 't' : A vector containing time values (e.g., 0:0.01:5).
% - 'x' : A matrix containing the system states, observer estimates, and CMO 
%   estimates across the time vector.
% - 'err' : A matrix containing the error for each system state over time.
% - 'estimate' : A matrix containing the CMO's final estimates for each system 
%   state over time.
% - 'sys' : A structure representing the system being observed, with fields 
%   such as 'nx' (number of states) and 'Name' (system name).
% - 'MO' : The multi-observer object that contains information about the system's
%   outputs and attack settings.
% - 'Jmo' : The J-observer configuration, containing the number of outputs 
%   observed by each J-observer.
% - 'Pmo' : The P-observer configuration, containing the number of outputs 
%   observed by each P-observer.
%
% Description:
% ------------
% The 'MOplot' function plots the system response, J-observers' estimates, 
% P-observers' estimates, the final CMO estimate, and the error for each 
% system state. It generates a grid of plots, where each subplot corresponds 
% to a specific state of the system. The function includes various customization 
% options like labels, legends, and plot titles for each state, as well as 
% different line styles for each plot element (e.g., system response, estimates, 
% and errors).
%
% Initialization Steps:
% ---------------------
% - The function first calculates the number of rows and columns for the plot 
%   grid based on the number of system states (sys.nx).
% - It separates the system's true response, J-observers' estimates, P-observers' 
%   estimates, and the CMO's estimate from the input 'x' matrix.
% - For each state, the system response, J-observer estimates, P-observer 
%   estimates, CMO estimate, and error are plotted in individual subplots.
% - A legend is added for each plot to distinguish between different curves 
%   (system response, J-observers, P-observers, CMO estimate, and error).
%
% Notes:
% ------
% - The function dynamically generates subplots for each system state.
% - The legend is adjusted to show the J-observers' and P-observers' estimates,
%   the system response, CMO estimate, and error for each state.
% - The number of rows and columns in the plot grid is calculated based on 
%   the total number of system states (sys.nx).
% - The error and CMO estimate are only plotted if the 'estimate' matrix 
%   contains multiple columns.
%
% See also:
% ---------
% mo, 3dcmo, ssmo
    
    fig = tiledlayout('flow');
    sgtitle({[char(sys.Name),' observed by a ' char(MO.Name) ' with ', num2str(MO.numOutputs),' outputs.'],...
        [ 'Number of attacks = ',num2str(MO.Attack.numAttacks)]});
        %,',N_J=',num2str(Jmo.numOutputsObservers),' and N_P=',num2str(Pmo.numOutputsObservers)]});
    
    % cmoEstimate = 
    trueResponse = x(1:sys.nx,:);
    JEstimates = x(sys.nx+1:sys.nx+Jmo.numObservers*sys.nx,:);
    PEstimates = x(sys.nx+Jmo.numObservers*sys.nx+1:end,:);
    yl = 1.05 * max(max(abs(trueResponse)));

    % create tiled plot
    for l = 1:1:sys.nx
        nexttile
        leg = [];
        % select subplot to edit
        
        % plot all p and j estimators
        try             
            for k=1:1:min(5,Jmo.numObservers)
                leg(2*k-1) = plot(t,JEstimates((k-1)*sys.nx+l,:),LineStyle="--",Color=[1 0 0 0.5]);
                hold on;
                if k < Pmo.numObservers
                    leg(2*k) = plot(t,PEstimates((k-1)*sys.nx+l,:),LineStyle="--",Color=[0 0 1 0.5]);
                    hold on;
                end
        
            end
        catch ME
            if strcmp(ME.identifier,"Unrecognized function or variable")
                warning("No Jmo supplied, will plot without Jmo.")
            end
        end
    
        % plot system response
        leg(end + 1) = plot(t,trueResponse(l,:),LineWidth=2,Color='black');
        hold on;
        
        % plot the cmo final estimate
        try
            if size(estimate,2) > 1
                leg(end + 1) = plot(t,estimate(l,:),LineWidth=1,Color='cyan');
                hold on;
            end
        catch ME
            if strcmp(ME.identifier,'Unrecognized function or variable')
                warning("No final esitmate is supplied, will plot without it.")
            end
        end
    
        % plot error
        try
            if size(estimate,2) > 1
                leg(end + 1) = plot(t,err(l,:),LineWidth=1,Color="#EDB120");
                hold on;
            end
        catch ME
            if strcmp(ME.identifier,"Unrecognized function or variable")
                warning("No error is supplied, will plot without it.")
            end
        end
        
        grid on;
        
        ylim([-yl yl])

        xlabel('Time')
        mass = floor((l+1)/2);

        if (-1)^l == -1
            % odd
            ylabel('Position')
            title(['Position of mass ' num2str(mass)])
        else
            % even
            ylabel('Velocity')
            title(['Velocity of mass ' num2str(mass)])
        end

    end
    
    % select the correct plots to add to legend
    if MO.Attack.numAttacks == 0
        lgd = legend([leg(end-2:end)],'System response','MO estimate','Error');
    elseif MO.Attack.numAttacks > 0
        lgd = legend([leg(1:2) leg(end-2:end)],'J-observers','P-observers','System response','MO estimate','Error');
    end

    lgd.Layout.Tile = 'east';

    set(gcf, 'Position', 0.4*get(0, 'Screensize'));
    hold on;
end