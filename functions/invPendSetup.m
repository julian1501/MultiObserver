function [sys,A,B,C,D] = invPendSetup(orientation,J)
    %% Dynamics
    % dynamic equations
    M = 5; % [kg] cart mass
    d = 150; % [N/m/s] friction coefficient cart
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
    
    n = size(A,1);
    C = zeros(J,n);
    I = eye(n);
    C(1:J,1:n) = I(1:J,1:n);

    sys = ss(A,B,C,0);

    disp(['Variables have been setup for the pendulum in ' orientation ' positon.'])
end