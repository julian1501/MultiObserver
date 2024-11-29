classdef msd
    % msd sets up a state space system for a mass-spring-damper (msd)
    %   Detailed explanation goes here

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
        % Nonlinear contribution matrix
        P
        % Linear
        Linear
        % number of states
        nx
        % number of outputs
        ny
        % number of inputs
        nu
    end

    methods
        function obj = msd(linear,numMass,m,k,c)
            %UNTITLED7 Construct an instance of this class
            %   Detailed explanation goes here
            obj.numMass = numMass;
            obj.Name = strcat(num2str(numMass), " mass-spring-damper");
            obj.Linear = linear;

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
                    P = 0;
                elseif ~linear
                    A = [0, 1; 0, -c(1)/m(1)];
                    P = [0; 1];
                end
                B = [0; 1/m(1)];
                % C should contain all rows that are valid outputs all rows should
                % individu
                C = [1 0;
                     0 1];
                D = 0;
            else
                A = zeros(2*numMass);
                if linear               
                    % Add state matrix entries for the first mass
                    A(1,2) = 1;
                    A(2,1:4) = [-(k(1)+k(2))/m(1), -(c(1)+c(2))/m(1), k(2)/m(1), c(2)/m(1)];
                
                    % Add state matrix entries for the last mass
                    A(end-1,end) = 1;
                    A(end,end-3:end) = [k(end)/m(end) c(end)/m(end) -k(end)/m(end) -c(end)/m(end)];
                    
                    % Add state matrix entries for intermediate matrices
                    for i = 2:1:numMass-1
                        A(2*i-1,2*i) = 1;
                        slice = [k(i) c(i) -(k(i)+k(i+1))/m(i), -(c(i)+c(i+1))/m(i), k(i+1)/m(i), c(i+1)/m(i)];
                        A(2*i,2*i-3:2*i+2) = slice;
                    end

                    % No non-linearities
                    P = 0;

                    % Set up B
                    B = zeros(2*numMass,numMass);
                    for i = 1:1:numMass
                        B(2*i,i) = 1/m(i);
                    end
                
                
                    % C should contain all rows that are valid outputs
                    C = zeros(numMass,2*numMass);
                    for i = 1:1:numMass
                        C(i,1:2*i) = repmat([1 0],1,i);
                    end

                    D = 0;

                elseif ~linear
                   error('Non linear model not possible for numMass: %2.0 > 1.',numMass)
                end

            end

            obj.A = A;
            obj.B = B;
            obj.C = C;
            obj.D = D;
            obj.P = P;
            obj.nx = size(A,1);
            obj.ny = size(C,1);
            obj.nu = size(B,2);

        end

    end
end