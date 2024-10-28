function [Astar, Bstar, Cstar] = systemStarSetup(A,B,AJ,BJ,LJ,CJ,J,Outputs)
%     This function creates an block matrix A* that combines all J observers into
%     a single state space form.
    n = size(A,1);
    k = size(BJ,2);
    m = size(CJ,1);
    
    
    % Nr = N + 1 because the original system does not count as one of the
    % outputs.
    AstarSize = Outputs + 1;    
    
    % Define Bstar
    Bstar = [B; BJ];

    % Define LC as left row of Astar 
    diagLC = LJ*CJ;
    LC = diagLC(:,1:n);
    
    % Add LjCj from Aj and place on the diagonal
    for l = 1:1:Outputs
        Start = (l-1)*(n) + 1;
        End   = (l-1)*(n) + n;
        AJ(Start:End,Start:End) = AJ(Start:End,Start:End) + LC(Start:End,1:n);
    end
    
    Astar = [A, zeros(size(A,1),size(AJ,2)); -LC, AJ];
    
    % Define an element of Cstar for each subsystem of Astar
    CstarElement = zeros(1,n);
    CstarElement(:,1:n/m) = ones(1,n/m);
    
    Cstar = diag(repmat(CstarElement,1,AstarSize));
%     Cstar(1:Asize,1:Asize) = zeros(Asize,Asize);
end