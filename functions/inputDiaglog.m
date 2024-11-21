function inputs = inputDiaglog(dialog)
    % inputs = inputDiaglog(obsvType) collects all user inputs that are
    % needed for the multi-observer.
    
    % Input dialog box
    inputPrompt = {'System selection (number indicates amount of mass-spring-dampers in series)',...
        'Number of system outputs',...
        'M, number of attacked outputs (max: largest integer M so that 2M<N holds)',...
        'Size of each P-observer (max: N-2M)',...
        'Eigenvalues (enter options separated by spaces)',...
        'Timespan (enter tmin and tmax separtated by spaces)',...
        'x0 (enter x0 seperated by spaces)'};
    
    definputs = {'2',...
        '10',...
        'max',...
        'max',...
        '-3 -4 -5 -6 -7 -8 -9 -10 -11 -12',...
        '0 5',...
        '0.3 -0.1 0.5 0.2 -0.4 0.6 0.3 0.3 -0.7 0.4 -0.2 0.6'};
    
    if dialog
        inputs = inputdlg(inputPrompt,'CMO inputs',[1 40],definputs);
    else
        inputs = definputs;
    end
end