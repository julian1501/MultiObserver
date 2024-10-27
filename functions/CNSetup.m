function CN = CNSetup(sys,N)
    % This function sets up the CN vector, which contains all N outputs
    % of the system. All rows are an output.
    % LTI system sys; number of outputs N; number of corrupted outputs M.
    A = sys.A;
    n = size(A,1);

    % Define observer Cs
    CN = zeros(N,n);
    j = 0;
    % Loop over every N rows and add 1s.
    for i = 1:1:N
        
        if j > n - 1
            j = 1;
        else
            j = j + 1;
        end
        CN(i,1) = 1;

    end

end