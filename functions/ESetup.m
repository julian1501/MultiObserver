function E = ESetup(Bstar,LJ,numObservers,sizeObserver)
    % This function defines the 'input-matrix' E based on the A,B and L
    % matrices of the system.
    
    % n is the size of a single block in an observer
    n = sizeObserver;
    k = size(Bstar,2);
    m = size(LJ,2);
    Esize1 = (numObservers+1)*n;
    Esize2 = k + numObservers*m + n;
    % Define the empty E matrix:
    %    Vertical: Esize1
    %    Horizontal: Number of inputs + (N x number of outputs per Cj) + n
    %       Number of outputs per Cj is 1 in current implementation, since
    %       a multiple output system is seen as a combination of different
    %       rows of CJ.
    E = zeros(Esize1,Esize2);
    
    % Add Bbar and Bbar to first column
    E(:,1:k) = Bstar;

    % Add Lj's to central section
    for l = 1:1:numObservers
        rowStart = l*n+1;
        rowEnd   = l*n+1 + n-1;
        colStart = k + (l-1)*m + 1;
        colEnd   = k + (l-1)*m + m ;
        E(rowStart:rowEnd,colStart:colEnd) = LJ((l-1)*n + 1:(l-1)*n + n ,:);
    end

    % Add In to right top slice
    E(1:n,end-n+1:end) = eye(n);

end