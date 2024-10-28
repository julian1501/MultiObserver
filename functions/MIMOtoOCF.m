function [OCFsys,Abar,Bbar,Cbar,Dbar] = MIMOtoOCF(system)
    % This function transforms the MIMO system (A,B,C,D) into observable
    % canonical form (Abar,Bbar,Cbar,Dbar).
    
    % Extract matrices
    A = system.A;
    B = system.B;
    C = system.C;
    D = system.D;
    n = size(A,1);
    m = size(C,1);
    k = size(B,2);
    
    % Step 1
    % Derive symbolic transfer function
    syms s
    sIA = s*eye(n) - A;
    symG = simplify((1/(det(sIA)))*C*adjoint(sIA)*B + D);

    % Step 2 find D by taking the limit of the transfer functions
    symDbar = limit(symG,s,inf);
    Dbar = double(symDbar);
    symGsp = symG - symDbar;

    % Step 3
    [~,GDenominators] = numden(symGsp);
    d = lcm(GDenominators);
    alpha = double(coeffs(d,'All'));
    % Divide Gsp by first coefficient of the denominator to force that as 1
    symGsp = simplify(symGsp/alpha(1));
    alpha = alpha(:,2:end)/alpha(1);
    

    % Step 4
    % subparts B are the coeficients that appear from the product d*Gsp,
    % these coefficients make up Bbar. coeffs gives the coefficients up to
    % the highest order of s, so the subparts need to be topped of with
    % zeros.
    subPartsB = simplify(-d*symGsp);
    Bbar = zeros(n*m,k);
    for l = 1:1:m
        % columns of B
        for p = 1:1:k
            % Extract coefficients from lth polynomial in subPartsB 
            Poly = subPartsB(l,p);
            coeffsPoly = double(coeffs(Poly,s,"All"));
            nrCoeffsPoly = size(coeffsPoly,2);
            coeffsPoly = [zeros(1,n-nrCoeffsPoly) coeffsPoly];
            % Place the coefficients in Bbar starting from the bottom
            for j = 1:1:n
                row = l + (j-1)*m;
                Bbar(row,p) = -coeffsPoly(j);
            end

        end
    
    end

    % Step 5 
    Abar = zeros(n*m,n*m);
    Cbar = zeros(m,m*n);
    Cbar(1:m,1:m) = eye(m);
    % Add -alpha*I to the left column
    for l = 1:1:n
        % select left row as -alpha_i*eye(m)
        rowStart = (l-1)*m+1;
        rowEnd   = (l-1)*m+1 + m - 1;
        Abar(rowStart:rowEnd,1:m) = -alpha(l)*eye(m);

        % Add I to the 'off' diagonal
        if l < n
            rowStart = (l-1)*m+1;
            rowEnd   = (l-1)*m+1 + m - 1;
            colStart = (l)*m+1;
            colEnd   = (l)*m+1 + m - 1;
            Abar(rowStart:rowEnd,colStart:colEnd) = eye(m);
        end
        
    end
    if size(Dbar,1) ~= size(Cbar,1)
        Dbar = 0;
    end

    OCFsys = ss(Abar,Bbar,Cbar,Dbar);

end