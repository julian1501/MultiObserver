function inputs = inputDialog(dialog)
% inputDialog Function
%
% The 'inputDialog' function collects user inputs needed for configuring 
% a multi-observer system. It displays a dialog box prompting for key 
% parameters or uses default inputs if the dialog is disabled.
%
% Documentation written by ChatGPT.
%
% Syntax:
% -------
% inputs = inputDialog(dialog)
%
% Inputs:
% -------
% - 'dialog': A logical value:
%     - 'true': Displays an input dialog box for the user to input values.
%     - 'false': Returns predefined default inputs without showing the dialog box.
%
% Outputs:
% --------
% - 'inputs': A cell array containing user-provided or default input values.
%
% Description:
% ------------
% This function is designed to gather the required parameters for the 
% configuration of a multi-observer system. The inputs collected include 
% system details, observer specifications, and simulation settings. 
% Depending on the value of 'dialog', the function either prompts the user 
% with a dialog box or returns predefined default inputs.
%
% Input Prompts:
% --------------
% The dialog box asks for the following inputs:
% 1. System selection: Number of mass-spring-dampers in series.
% 2. Number of system outputs: Total outputs of the system.
% 3. Number of attacked outputs ('M'): Specify 'M', with a constraint 
%    '2M < N' (where 'N' is the number of outputs).
% 4. Size of each P-observer: Enter the size, constrained by 'N-2M'.
% 5. Eigenvalues: Specify eigenvalue options separated by spaces.
% 6. Timespan: Enter 'tmin' and 'tmax' separated by spaces.
% 7. Initial state ('x0'): Specify initial conditions separated by spaces.
% 8. Observers: Enter a binary string indicating the use of:
%    - 'CMO2D': 1st bit.
%    - 'CMO3D': 2nd bit.
%    - 'SSMO': 3rd bit.
% 9. System type: Specify if the system is:
%    - Linear: '1'.
%    - Nonlinear: '0'.
%
% Default Inputs:
% ---------------
% If the dialog is disabled ('dialog = false'), the function returns the 
% following predefined inputs:
% 1. 'System selection': '2'.
% 2. 'Number of system outputs': '6'.
% 3. 'Number of attacked outputs': '2'.
% 4  'Attacked outputs': ''.
% 5. 'Size of each P-observer': 'max'.
% 6. 'Eigenvalues': '-3 -4 -5 -6 -7 -8 -9 -10 -11 -12 -13 -14'.
% 7. 'Timespan': '0 5'.
% 8. 'Initial state ('x0')': 
%    '0.3 -0.1 0.5 0.2 -0.4 0.6 0.3 0.3 -0.7 0.4 -0.2 0.6'.
% 9. 'Observers': '0 1 1 0'.
% 10. 'System type': '0'.
% 11. 'Noise intensity': '0'.
%
% Example:
% --------
% Using the dialog:
% inputs = inputDialog(true);
% Prompts the user for inputs using an input dialog box.
% Using default inputs:
% inputs = inputDialog(false);
% Returns:
% inputs = {'2', '6', '2', 'max', '-3 -4 -5 -6 -7 -8 -9 -10 -11 -12 -13 -14', ...
%           '0 5

    
    % Input dialog box
    inputPrompt = {'System selection (number indicates amount of mass-spring-dampers in series)',...
        'Number of system outputs',...
        'M, number of attacked outputs (max: largest integer M so that 2M<N holds)',...
        'Attacked outputs (empty string will attack random outputs)',...
        'Size of each P-observer (max: N-2M)',...
        'Eigenvalues (enter options separated by spaces)',...
        'Timespan (enter tmin and tmax separtated by spaces)',...
        'x0 (enter x0 seperated by spaces)',...
        'CMO2D CMO3D SSMO',...
        'Linear (1) or Nonlinear (0) model',...
        'Noise variance (generated with randn)'};
    
    % Prefilled inputs
    definputs = {'2',...
        '6',...
        '2',...
        '',...
        '1',...
        '-3 -4 -5 -6 -7 -8 -9 -10 -11 -12 -13 -14',...
        '0 5',...
        '0.3 -0.1 0.5 0.2 -0.4 0.6 0.3 0.3 -0.7 0.4 -0.2 0.6',...
        '0 1 0',...
        '0',...
        '0'};
    
    % Check if input is required, ohterwise use prefilled inputs
    if dialog
        inputs = inputdlg(inputPrompt,'CMO inputs',[1 40],definputs);
    else
        inputs = definputs;
    end
end