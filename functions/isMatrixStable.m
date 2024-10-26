function stableBool = isMatrixStable(A)
    % Check if the matrix A is stable, e.g. all eigenvalues have a strictly
    % negative real part.

    % Initialize stableBool as true
    stableBool = true;
    eigenvalues = eig(A);
    n = size(eigenvalues,1);
    % Loop through eigenvalues and compare each eigenvalue to 0
    for i = 1:1:n
        if eigenvalues(i) > 0
            stableBool = false;
        end
    end
end