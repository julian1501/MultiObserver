function [sys,A,B,C,D] = invPendSetup(orientation)
%   Orientation = 'up' or 'down'
    clearvars -except orientation;
    close all;
    %% Dynamics
    % dynamic equations
    M = 5; % [kg] cart mass
    d = 50; % [N/m/s] friction coefficient cart
    c = 40; % friction coefficient pendulum
    m = 1; % [kg] pendulum mass
    l = 2; % [m] pendulum length
    g = -9.81;% [m/s^2]
%     Check orientation
    if strcmp(orientation,'up')
        b = 1;
    elseif strcmp(orientation,'down')
        b = -1;
    else 
        error("Orientation needs to be either 'up' or 'down'")
    end
    
    %% State space model
    % Imported from 'databook-1.pdf' from Steve Brunton YouTube videos
    A = [0          1                0        0;
         0       -d/M          b*m*g/M        0;
         0          0                0        1;
         0 -b*d/(M*l) -b*(m+M)*g/(M*l)        0];
    
    B = [0;       1/M;               0; b/(M*l)];
    
    C = [1 0 0 0];

    sys = ss(A,B,C,0);

    disp(['Variables have been setup for the pendulum in ' orientation ' positon.'])
end