function [Astar, Bstar, Cstar] = CMOSetup(A,B,LJ,CJ,Outputs)
%     This function creates an block matrix A* that combines all J observers into
%     a single state space form.
    n = size(A,1);
    k = size(B,2);
    
    
    % Nr = N + 1 because the original system does not count as one of the
    % outputs.
    AstarSize = Outputs + 1;
    % Define empty transformed matrices.
    Astar = zeros(n*AstarSize,n*AstarSize);
    Bstar = zeros(n*AstarSize,k);
    
    % Replcace the top left (n x n) block by A
    Astar(1:n,1:n) = A;
    % Set top block of Bstar as B
    Bstar(1:n,1:k) = B;

    % Loop through the new Astar matrix and replace slices sized Asize by
    % Asize with the corresponding matrix. l is looping variable that loops
    % through the all blocks of Astar.
    for block = 2:1:AstarSize
        % j indicates the absolute index, where block indicates the 'block'
        % index.
        absoluteIndex = n*block - n+1;
        
        % Select the matrices L and J to be used in this iteration
        L = LJ(:,block-1);
        C = CJ(block-1,:);

        % Replace the block (i,i) with A, where i=1,2,...,Astarsize
        Astar(absoluteIndex:absoluteIndex+n-1,absoluteIndex:absoluteIndex+n-1) = A+L*C;
        % Replace the block on the left size with -LC.
        Astar(absoluteIndex:absoluteIndex+n-1,1:n) = -L*C;
        % Add B to the block matrix Bstar. Bstar is Asize copies of B below
        % each other.
        Bstar(absoluteIndex:absoluteIndex+n-1,1:k) = B;
    
    end
    
    Cstar = eye(n*AstarSize,n*AstarSize);
%     Cstar(1:Asize,1:Asize) = zeros(Asize,Asize);
end