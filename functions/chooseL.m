function L = chooseL(A,C,eigenvalues)
    % This function chooses L such that the eigenvalues of A+LC are at
    % 'eigenvalues'. Compatible with MIMO systems. Only works on systsems
    % in observable canonical form. NO CHECK IMPLEMENTED.

    % Extract n (number of states) and m (number of outputs).
    n = size(A,1);
    m = size(C,1);

    % Extract characteristic polynomial from a
    alpha = charpoly(A);
    desired = rootsToCoefficients(eigenvalues);
    % Define (m x m) identity matrix.
    I = eye(m);
    
    % Define empty (n x m) L matrix
    L = zeros(n,m);
    
    % Loop through all blocks of L and add (alpha-desired)I, where alpha is the
    % coefficient of the characteristic polynomial of A and desired is the
    % coefficient of the characteristic polynomial of A+LC where L places
    % the eigenvalues in the desired locations.
    for l = 1:1:n
        L(l:l+m-1,1:m) = (alpha(1,l+1)-desired(1,l+1))*I;
    end

end