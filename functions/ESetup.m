function E = ESetup(B,LJ,N)
    % This function defines the 'input-matrix' E based on the A,B and L
    % matrices of the system.
    
    n = size(B,1);
    k = size(B,2);
    m = 1;
    Esize1 = (N+1)*n;
    Esize2 = k + N*m + n;
    % Define the empty E matrix:
    %    Vertical: Esize1
    %    Horizontal: Number of inputs + (N x number of outputs per Cj) + n
    %       Number of outputs per Cj is 1 in current implementation, since
    %       a multiple output system is seen as a combination of different
    %       rows of CJ.
    E = zeros(Esize1,Esize2);

    % Add B's to first column
    for l = 1:1:(N+1)
        rowStart = l*n-1;
        rowEnd   = l*n-2+n;
        colStart = 1;
        colEnd   = k;
        E(rowStart:rowEnd,colStart:colEnd) = B;
    end

    % Add Lj's to central section
    for l = 1:1:N
        rowStart = l*n+1;
        rowEnd   = l*n+1 + n-1;
        colStart = k + l*m;
        colEnd   = k + l*m + m - 1;
        E(rowStart:rowEnd,colStart:colEnd) = LJ(l);
    end

    % Add In to right top slice
    E(1:n,end-n+1:end) = eye(n);

end