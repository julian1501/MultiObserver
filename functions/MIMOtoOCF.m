function [OCFsys,Abar,Bbar,Cbar,Dbar] = MIMOtoOCF(system)
    % This function transforms the MIMO system (A,B,C,D) into observable
    % canonical form (Abar,Bbar,Cbar,Dbar).
    
    % Extract matrices
    A = system.A;
    B = system.B;
    C = system.C;
    D = system.D;
    numStates = size(A,1);
    numOutputs = size(C,1);
    numInputs = size(B,2);
    
    % Step 1
    % Derive symbolic transfer function
    syms s
    sIA = s*eye(numStates) - A;
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
    Bbar = zeros(numStates*numOutputs,numInputs);
    for l = 1:1:numOutputs
        % columns of B
        for p = 1:1:numInputs
            % Extract coefficients from lth polynomial in subPartsB 
            Poly = subPartsB(l,p);
            coeffsPoly = double(coeffs(Poly,s,"All"));
            nrCoeffsPoly = size(coeffsPoly,2);
            coeffsPoly = [zeros(1,numStates-nrCoeffsPoly) coeffsPoly];
            % Place the coefficients in Bbar starting from the bottom
            for j = 1:1:numStates
                row = l + (j-1)*numOutputs;
                Bbar(row,p) = -coeffsPoly(j);
            end

        end
    
    end

    % Step 5 
    Abar = zeros(numStates*numOutputs,numStates*numOutputs);
    Cbar = zeros(numOutputs,numOutputs*numStates);
    Cbar(1:numOutputs,1:numOutputs) = eye(numOutputs);
    % Add -alpha*I to the left column
    for l = 1:1:numStates
        % select left row as -alpha_i*eye(m)
        rowStart = (l-1)*numOutputs+1;
        rowEnd   = (l-1)*numOutputs+1 + numOutputs - 1;
        Abar(rowStart:rowEnd,1:numOutputs) = -alpha(l)*eye(numOutputs);

        % Add I to the 'off' diagonal
        if l < numStates
            rowStart = (l-1)*numOutputs+1;
            rowEnd   = (l-1)*numOutputs+1 + numOutputs - 1;
            colStart = (l)*numOutputs+1;
            colEnd   = (l)*numOutputs+1 + numOutputs - 1;
            Abar(rowStart:rowEnd,colStart:colEnd) = eye(numOutputs);
        end
        
    end
    if size(Dbar,1) ~= size(Cbar,1)
        Dbar = 0;
    end

    OCFsys = ss(Abar,Bbar,Cbar,Dbar);

end