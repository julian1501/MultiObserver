function CJ = CJSetup(sys,N,M)
    % This function sets up the CJ vector, which contains all N observers
    % of the multiobserver. All rows are an observer.
    % LTI system sys; number of outputs N; number of corrupted outputs M.
    A = sys.A;
    B = sys.B;
    C = sys.C;
    n = size(A,1);

    % number of uncorrupted sensor combinations
    J = nchoosek(N,N-M);
    P = nchoosek(N,N-2*M);

    % Define observer Cs
    CJ = zeros(N,n);
    j = 0;
    % Loop over every N rows and add 1s.
    for i = 1:1:N
        
        if j > n - 1
            j = 1;
        else
            j = j + 1;
        end
        CJ(i,1) = 1;

    end

end