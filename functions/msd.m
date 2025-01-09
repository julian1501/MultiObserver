classdef msd
% msd Class
%
% The 'msd' class defines a mass-spring-damper (MSD) system using state-space 
% representation. It sets up a linear or nonlinear system with multiple masses 
% in series and calculates the system matrices A, B, C, D, and optionally E 
% for nonlinearities.
%
% Documentation written by ChatGPT.
%
% Properties:
% -----------
% - 'numMass': The number of masses in the system.
% - 'Name': The name of the system, constructed using the number of masses.
% - 'A': The state-space A matrix, describing the system's dynamics.
% - 'B': The state-space B matrix, representing the system inputs.
% - 'C': The state-space C matrix, representing the system outputs.
% - 'D': The state-space D matrix, which typically relates inputs to outputs.
% - 'E': The nonlinear E matrix (if applicable), defining the nonlinear behavior.
% - 'Linear': A boolean indicating whether the system is linear or nonlinear.
% - 'nx': The number of states in the system, corresponding to the size of the A matrix.
% - 'ny': The number of outputs in the system, corresponding to the size of the C matrix.
% - 'nu': The number of inputs to the system, corresponding to the size of the B matrix.
% - 'xsize': The size of the state vector (calculated based on the number of masses).
% - 'k': The spring constants for each mass.
% - 'a': A constant used in the nonlinear model (default value of 10).
% - 'm': The masses in the system.
% - 'NLsize': The size of the nonlinear matrix E (if applicable).
% - 'COutputs': The matrix of valid outputs for the system.
%
% Methods:
% --------
% - 'msd(linear, numMass, m, k, c)': Constructor to initialize an instance of the 
%   'msd' class.
%   - 'linear': A boolean indicating whether the system is linear (true) or nonlinear (false).
%   - 'numMass': The number of masses in the system.
%   - 'm': A vector containing the masses in the system.
%   - 'k': A vector containing the spring constants for each mass.
%   - 'c': A vector containing the damping constants for each mass.
%
% Constructor Description:
% ------------------------
% The constructor initializes the mass-spring-damper system based on the 
% provided parameters. It constructs the system matrices A, B, C, D, E, and P 
% depending on whether the system is linear or nonlinear. If the system has 
% nonlinearities, it will set up the appropriate nonlinear matrix E. 
% The constructor also checks that the system is observable and validates the 
% input constants. If multiple constants are provided, they are repeated for 
% each mass.
%
% Initialization Steps:
% ---------------------
% - The constructor checks that only one constant for spring, mass, and damping 
%   is provided, and replicates it for each mass if necessary.
% - If the system is linear, it sets up the A matrix for a linear system with 
%   the appropriate entries for each mass and its interactions.
% - If the system is nonlinear, it sets up the A matrix similarly but includes 
%   additional nonlinear terms and sets the nonlinear matrices E and P.
% - The system matrices B and C are set up based on the number of masses.
% - The constructor also checks that the system is observable by calling 
%   the MATLAB function `isObsv()`.
%
% Example:
% --------
% linear = true;  % Set to false for a nonlinear system
% numMass = 2;
% m = [1; 1];  % Masses of each block
% k = [10; 10];  % Spring constants
% c = [0.5; 0.5];  % Damping constants
%
% sys = msd(linear, numMass, m, k, c);
% This creates a linear 2-mass mass-spring-damper system with the specified 
% parameters.
%
% Notes:
% ------
% - If a nonlinear system is chosen, the matricex E is populated to 
%   represent nonlinear contributions to the system.
% - The system matrices (A, B, C, D, E, and P) are computed based on the 
%   configuration of the mass-spring-damper system (linear or nonlinear).
% - The constructor automatically checks for observability and throws an error 
%   if the system is not observable.
% - The class is capable of handling multiple masses in series and adjusting 
%   the system dynamics accordingly.
%
% See also:
% ---------
% isObsv


    properties
        % Number of masses in series
        numMass 
        % Name of the system
        Name
        % State-space A matrix
        A
        % State-space B matrix
        B
        % State-space C matrix
        C
        % State-space D matrix
        D
        % Nonlinear E multiplication matrix
        E
        % Linear
        Linear
        % number of states
        nx
        % number of outputs
        ny
        % number of inputs
        nu
        % size of eventual x
        xsize

        k

        a

        m

        NLsize

        COutputs
    end

    methods
        function obj = msd(linear,numMass,m,k,c)
            %UNTITLED7 Construct an instance of this class
            %   Detailed explanation goes here
            obj.numMass = numMass;
            obj.Name = strcat(num2str(numMass), " mass-spring-damper");
            obj.Linear = linear;
            obj.k = k;
            obj.a = 10;
            obj.m = m;

            % Check if only one constant is provided and create multiples
            if size(k,1) > 1 || size(m,1) > 1 || size(c,1) > 1
                error('Provide only one constant, it will be repeated.')
            else
                m = repmat(m,numMass,1);
                k = repmat(k,numMass,1);
                c = repmat(c,numMass,1);
            end
        
            if numMass == 1
                if linear
                    A = [0, 1; -k(1)/m(1), -c(1)/m(1)];
                    E = [];
                elseif ~linear
                    A = [0, 1; -k(1)/m(1), -c(1)/m(1)];
                    E = [0; -1];
                end
                B = [0; 1/m(1)];
                % C should contain all rows that are valid outputs all rows should
                % individu
                C = [1 0];
                D = 0;
            else
                A = zeros(2*numMass);
                if linear               
                    % Add state matrix entries for the first mass
                    A(1,2) = 1;
                    A(2,1:4) = [-(k(1)), -c(1), k(2), c(2)]./m(1);
                
                    % Add state matrix entries for the last mass
                    A(end-1,end) = 1;
                    A(end,end-3:end) = [0 0 -k(end) -c(end)]./m(end);
                    
                    % Add state matrix entries for intermediate matrices
                    for i = 2:1:numMass-1
                        A(2*i-1,2*i) = 1;
                        slice = [0 0 -k(i), -c(i), k(i+1), c(i+1)]./m(i);
                        A(2*i,2*i-3:2*i+2) = slice;
                    end

                    % No non-linearities
                    E = [];

                    

                elseif ~linear
                   
                   % Add state matrix entries for the first mass
                    A(1,2) = 1;
                    A(2,1:4) = [-k(1), -(c(1)), k(2), c(2)]./m(1);
                
                    % Add state matrix entries for the last mass
                    A(end-1,end) = 1;
                    A(end,end-3:end) = [0 0 -k(end) -c(end)]./m(end);
                    
                    % Add state matrix entries for intermediate matrices
                    for i = 2:1:numMass-1
                        A(2*i-1,2*i) = 1;
                        slice = [0 0 -k(i) -c(i) k(i+1) c(i+1)]./m(i);
                        A(2*i,2*i-3:2*i+2) = slice;
                    end

                    % non-linearities
                    E = zeros(2*numMass,numMass);
                    for i = 1:1:numMass
                        if i < numMass
                            E(2*i,i:i+1) = [-1/m(i) 1/m(i)];
                        else
                            E(2*i,i) = -1/m(i);
                        end
                    end
                                        
%                     error('Non linear model not possible for numMass: %2.0 > 1.',numMass)
                end

                % Set up B
                B = zeros(2*numMass,numMass);
                for i = 1:1:numMass
                    B(2*i,i) = 1/m(i);
                end
            
            
                % C should contain all rows that are valid outputs
                C = zeros(numMass,2*numMass);
                for i = 1:1:numMass
                    C(i,1:2*i) = [repmat([1 0],1,i)];
%                     C = [1 zeros(1, 2*numMass-1)];
                end

                D = 0;

            end

            % check for observability
            if ~isObsv(A,C)
                error('The system is not observable')
            end

            obj.A = A;
            obj.B = B;
            obj.C = C;
            obj.D = D;
            obj.E = E;
            obj.nx = size(A,1);
            obj.ny = size(C,1);
            obj.nu = size(B,2);
            obj.NLsize = size(E,2);

        end

    end
end