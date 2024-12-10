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
        % Nonlinear E multiplication matrix
        E
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
                    P = [0; 0];
                    E = [];
                elseif ~linear
                    A = [0, 1; -k(1)/m(1), -c(1)/m(1)];
                    P = [0; 1];
                    E = [0 0; 0 -1];
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
                    P = zeros(2*numMass,1);
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
                    P = repmat([0;1],numMass,1);
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
            obj.P = P;
            obj.nx = size(A,1);
            obj.ny = size(C,1);
            obj.nu = size(B,2);
            obj.NLsize = size(E,2);

        end

    end
end