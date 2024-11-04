function L = chooseL(A,C,eigenvalues,originalStates)
    % This function chooses L such that the eigenvalues of A+LC are at
    % 'eigenvalues'. Compatible with MIMO systems. Only works on systsems
    % in observable canonical form. NO CHECK IMPLEMENTED.

    % Extract n (number of states) and m (number of outputs).
    n = size(A,1);
    m = size(C,1);

    % Extract characteristic polynomial from a
    alpha = charpoly(A);
    % Derive desired polynomial based on given eigenvalues
    desired = rootsToCoefficients(eigenvalues);
    desired = desired(:,2:end);
    % Define (m x m) identity matrix.
    I = eye(m);
    
    % Define the desired A in OCF
    Ad = zeros(n,n);
    % Add -alpha_l I
    for l = 1:1:originalStates
        Start = (l-1)*m+1;
        End   = Start + m -1;
        Ad(Start:End,1:m) = -desired(l)*I;
    end
    % Replace to right section of Ad with an eye(n-m)
    Ad(1:n-m,end-n+m+1:end) = eye(n-m);
    
    % Select L from the first m columns of Ad-A
    L = Ad - A;
    L = L(:,1:m);

end