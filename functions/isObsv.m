function bool = isObsv(A,C)
    % This function determines if the pair A, C is observable. It checks
    % if the rank matches the size of the matrix. A must be a square (nxn)
    % matrix and C must be a (mxn) matrix.
    n = size(A,1);
    ev = eig(A);
    I = eye(n);
    % PBH test
    bool = true;
    for i = 1:1:n
        if rank([ev(i)*I - A; C]) ~= n
            bool = false;
            break
        end
    end
    

end