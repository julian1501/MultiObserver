function NLk = NLspring(sys,x)
    % NLk = NLspring(x,k,a) describes a non-linear hardening spring, 
    % 
    if sys.NLsize == 0
        NLk = [];
    else
        NLk = zeros(size(x));
        for i = 1:1:size(x,3)
            % Edit function below for changing spring
            for j = 1:1:sys.nx
                if sys.P(j,1) == 1
                    d = x(1,:,i);
                    NLk(2,:,i) = - sys.k*(1 + sys.a^2*d^2)*d/sys.m;
                end
                
            end
    
        end

    end

end