function [stableBool, stableIndices] = isALJCJStable(A,LJ,CJ,N)
    % Determine if the all elements of the system AJ + LJCJ are stable.
    % Returns a boolean value indicating if everything is stable or not and
    % returns the inddices where true indicates a stable row and false
    % indicates an unstable row of A+LJCJ.
    
    % Define stableBool as true stableIndices as all rows 0
    stableBool = true;
    stableIndices = zeros(N,1);

    for l = 1:1:N
        L = LJ(:,l);
        C = CJ(l,:);
        if ~isMatrixStable(A+L*C)
            stableBool = false;
            stableIndices(l) = false;
        else
            stableIndices(l) = true;
        end
    end