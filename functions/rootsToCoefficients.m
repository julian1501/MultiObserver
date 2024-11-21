function coefficients = rootsToCoefficients(roots)
    % This function provides the coefficients of the polynomial with roots
    % 'roots'. 'roots' needs to be a (1 x n) or (n x 1) matrix. Returns
    % coefficients with highest order coefficient in first position.

    % Format roots into (1xn) matrix
    rootsSize = size(roots);
    % Throw error if roots is not (1 x n) or (n x 1)
    if rootsSize(1) > 1 && rootsSize(2) > 1
        error('Input variable roots is not (1 x n) or (n x 1).', roots);
    % Flip roots into (1 x n) if it is (n x 1).
    elseif rootsSize(1) > 1
        roots = roots';
    end
    % Define polynomial (x - root1)...(x-rootn) and extract coefficients.
    x = sym("x");
    desiredPolynomial = expand(prod(x-roots));
    coefficients = double(coeffs(desiredPolynomial));
    % flip coefficients to arrange highest order coefficient left and
    % counting down
    coefficients = fliplr(coefficients);

end