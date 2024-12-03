function NLk = NLspring(sys,x)
    % NLk = NLspring(x,k,a) describes a non-linear hardening spring, 
    % 
    NLk = zeros(size(x));
    for i = 1:1:size(x,3)
        % Edit function below for changing spring
        NLk(2,:,i) = -(sys.k*x(1,:,i))^3/sys.m;
    end

end