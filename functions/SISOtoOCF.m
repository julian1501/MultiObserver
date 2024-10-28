function [OCFsys,Abar,Bbar,Cbar,Dbar] = SISOtoOCF(sys)
% This function rewrites the SISO system (A,B,C,D) into observable canonical
% form (Abar, Bbar, Cbar, Dbar). It uses a similarity transformation T,
% where T is the last column of the inverse of the observability matrix of
% the pair (A,C).
    A = sys.A;
    B = sys.B;
    C = sys.C;
    D = sys.D;
    
    % Check observability of (A,C) to guarantee that T will be non-singular
    if ~isObsv(A,C)
        error('The pair (A,C) is not observable and thus the transformation into OCF is not possible.')
    end
    n = size(A,1);

    invO = inv(obsv(A,C));
    q = invO(:,end);

    Tinv = zeros(n);
    for i = 1:1:n
        Tinv(:,i) = A^(n-i)*q;
    end
    T = inv(Tinv);
    
    Abar = T*A*Tinv;
    Bbar = T*B;
    Cbar = C*Tinv;
    Dbar = D;

    OCFsys = ss(Abar,Bbar,Cbar,Dbar);

end
