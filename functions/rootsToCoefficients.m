function coefficients = rootsToCoefficients(roots)
% rootsToCoefficients Function
%
% The 'rootsToCoefficients' function computes the coefficients of a polynomial 
% given its roots. The resulting coefficients are returned in descending order 
% of powers, starting with the highest order term.
%
% Documentation written by ChatGPT.
%
% Inputs:
% -------
% - 'roots': A vector (either row or column) of polynomial roots. The input 
%   must be either a (1 × n) or (n × 1) matrix, where 'n' is the number of roots.
%
% Outputs:
% --------
% - 'coefficients': A row vector containing the coefficients of the polynomial 
%   in descending order of powers, with the coefficient of the highest order 
%   term appearing first.
%
% Function Description:
% ---------------------
% The function takes the roots of a polynomial and computes its coefficients 
% by expanding the polynomial expression (x - r_1)(x - r_2)*...*(x - r_n). 
% The resulting coefficients are formatted into a vector with the highest 
% order term's coefficient at the start.
%
% Implementation Steps:
% ---------------------
% 1. The input 'roots' is checked to ensure it is either a row or column 
%    vector. If not, an error is thrown.
% 2. If 'roots' is a column vector, it is transposed to a row vector for 
%    consistency.
% 3. A symbolic polynomial (x - r_1)(x - r_2)*...*(x - r_n) is constructed 
%    using the roots.
% 4. The 'coeffs' function extracts the polynomial's coefficients.
% 5. The coefficients are flipped ('fliplr') to ensure they are returned in 
%    descending order of powers.
%
% Notes:
% ------
% - The function uses symbolic math ('sym') for polynomial expansion and 
%   coefficient extraction.
% - Ensure that the input 'roots' is a real or complex vector; matrices or 
%   multi-dimensional arrays are not supported.
% - The function ensures that the output is a numeric array by converting 
%   symbolic coefficients to doubles.
%
% Error Handling:
% ---------------
% - If 'roots' is neither a row nor a column vector, the function throws an 
%   error with the message: 
%   'Input variable roots is not (1 x n) or (n x 1).'
%
% See also:
% ---------
% sym, expand, coeffs, fliplr


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