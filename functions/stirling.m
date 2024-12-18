function fact = stirling(n)
% stirling Function
%
% This function calculates an approximation of the factorial of a given 
% integer 'n' using Stirling's approximation.
%
% This documentation is written with the help of ChatGPT
%
% Syntax:
% -------
% 'fact = stirling(n)'
%
% Inputs:
% -------
% - 'n': A positive integer for which the factorial is to be approximated.
%
% Outputs:
% --------
% - 'fact': The Stirling's approximation of 'n!' (factorial of 'n').
%
% This formula is particularly useful for large values of 'n' where direct 
% computation of 'n!' may be computationally expensive or infeasible due to 
% numerical limitations.
%
% Example:
% --------
% % Compute the approximate factorial using Stirling's formula
% n = 10; % Example value
% fact = stirling(n);
% disp(fact);
%
% Notes:
% ------
% - This function is an efficient way to estimate factorials for large 'n', 
%   but the approximation becomes less accurate for smaller values of 'n'.
% - For small values of 'n', it may be better to use the 'factorial' 
%   function in MATLAB for exact results.
%
% See also:
% ---------
% factorial, log, exp

    fact = sqrt(2*pi*n)*(n/exp(1))^n;
end