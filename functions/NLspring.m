function NLk = NLspring(x,k,a)
    % NLk = NLspring(x,k,a) describes a non-linear hardening spring, 
    % formula taken from page 9 Nonlinear Systems by Khalil Hassan.
    NLk = k*(1-a^2*x^2)*x;
end