function inputs = inputDiaglog
    %% USER INPUTS
    % There are more parameters that can be changed, some things nested within
    % functions.
    
    % Input dialog box
    inputPrompt = {'System selection (number indicates amount of mass-spring-dampers in series)',...
        'Number of system outputs',...
        'M, number of attacked outputs (max: largest integer M so that 2M<N holds)',...
        'Eigenvalue options (enter options separated by spaces)',...
        'Timespan (enter tmin and tmax separtated by spaces)',...
        'x0 (enter x0 seperated by spaces)',...
        'Attack signal (0 is no attack)'};
    
    definputs = {'1',...
        '5',...
        'max',...
        '-3 -4 -5 -6 -7 -8',...
        '0 5',...
        '0.3 -0.1 0.5 0.2 -0.4 0.6 0.3 0.3 -0.7 0.4 -0.2 0.6',...
        '0'};
    
    inputs = inputdlg(inputPrompt,'CMO inputs',[1 40],definputs);
end