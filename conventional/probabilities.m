clearvars
% Define system parameters
max_N_S = 20;
N_phi = 2;
max_N_M = 10;

looseProbs =  zeros((max_N_S-6)/2,max_N_S);
strictProbs = zeros((max_N_S-6)/2,max_N_S);

for N_S = 6:2:max_N_S
    looseProbsRow = findProbabilities(N_S, N_phi, N_S, 'loose');
    % fprintf(append('N_S = ',string(N_S),', N_phi = ', string(N_phi),' ', 'loose grouping','\n'))
    % looseT = array2table(looseProbs);
    % looseT = renamevars(looseT,1:1:max_N_M,string(1:1:max_N_M));
    % looseT.Properties.RowNames = {'p(robust)','p(not robust)'};
    % disp(looseT)
    
    strictProbsRow = findProbabilities(N_S, N_phi, N_S, 'strict');
    % fprintf(append('N_S = ',string(N_S),', N_phi = ', string(N_phi),' ', 'strict grouping','\n'))
    % strictT = array2table(strictProbs);
    % strictT = renamevars(strictT,1:1:max_N_M,string(1:1:max_N_M));
    % strictT.Properties.RowNames = {'p(robust)','p(not robust)'};
    % disp(strictT)

    looseProbs((N_S-6)/2 + 1,1:size(looseProbsRow,2))  =  looseProbsRow(1,:);
    strictProbs((N_S-6)/2 + 1,1:size(looseProbsRow,2)) = strictProbsRow(1,:);
end

function probs = findProbabilities(N_S, N_phi, max_N_M, grouping)
    % create groups
    S = 1:1:N_S;
    same_sensors = reshape(S,N_phi,[],1);
    grouped_sensors = combinations(same_sensors,grouping);
    N_O = size(grouped_sensors,1);
    
    probs = zeros(2,max_N_M);
    % loop over all number of attacks until max_N_M
    for N_M = 1:1:max_N_M
        % number of possible attack combinations
        num_attack_combs = nchoosek(N_S,N_M);
        attack_combs  = nchoosek(S,N_M);
        
        % intialize counters
        robust = 0;
        unrobust = 0;
        
        % loop over all attack combinations
        for c = 1:1:num_attack_combs
            comb = attack_combs(c,:);
            
            % intialize counter
            N_A = 0;
            for g = 1:1:N_O
                % if any entry of the combination is a member of the sensor
                % group add one to N_A
                if any(ismember(comb,grouped_sensors(g,:)))
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
        probs(1,N_M) = robust/num_attack_combs;
        probs(2,N_M) = unrobust/num_attack_combs;
    end
end