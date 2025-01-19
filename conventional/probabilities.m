% Define system parameters
N_S = 15;
N_phi = 3;
N_O = N_S/N_phi;
max_N_M = 7;

% create groups
S = 1:1:N_S;
grouped_sensors = reshape(S,N_phi,1,[]);
groups = size(grouped_sensors,3);

% define empty probability matrix
probs = zeros(2,max_N_M);

% loop over all number of attacks until max_N_M
for N_M = 1:1:max_N_M
    % number of possible attack combinations
    ncombs = nchoosek(N_S,N_M);
    combs  = nchoosek(S,N_M);
    
    % intialize counters
    robust = 0;
    unrobust = 0;

    % loop over all attack combinations
    for c = 1:1:ncombs
        comb = combs(c,:);
        
        % intialize counter
        N_A = 0;
        for g = 1:1:groups
            % if any entry of the combination is a member of the sensor
            % group add one to N_A
            if any(ismember(comb,grouped_sensors(:,:,g)))
                N_A = N_A + 1;
            end
        end
        
        % check if robustness condition holds, add one to robust if it
        % does, add one to unrobust if it doesn't
        if 2*N_A < N_O
            robust = robust + 1;
        else
            unrobust = unrobust + 1;
        end

    end
    
    % Calculate share of combinations that are robust and not robust
    probs(1,N_M) = robust/ncombs;
    probs(2,N_M) = unrobust/ncombs;
end