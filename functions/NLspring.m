function NLk = NLspring(sys,y)
    % NLk = NLspring(x,k,a) describes a non-linear hardening spring, 
    % 
    if sys.NLsize == 0
        NLk = [];
    else
        NLk = zeros(sys.NLsize,1);
        dPrev = 0;
        for j = 1:1:sys.NLsize
            d = y(j) - dPrev;
            dPrev = dPrev + d;
            NLk(j) = (sys.k*sys.a^2*d^3)/sys.m;
        end

    end

end