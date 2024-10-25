function [Astar, Bstar, Cstar] = CMOSetup(A,B,L,CJ,N)
%     This function creates an A* matrix that combines all J observers into
%     a single state space form.
    n = size(A,1);
    k = size(B,2);

    Astar = zeros(n*N,n*N);
    Bstar = zeros(n*N,k);
    for i = 1:1:N
        j = 4*i - 3;
        Astar(j:j+n-1,j:j+n-1) = A;
        if i > 1
          Astar(j:j+n-1,1:4) = -L*CJ(i,:);
        end
        
        Bstar(j:j+n-1,1:k) = B;
    
    end
    
    Cstar = eye(n*N,n*N);
    Cstar(1:n,1:n) = zeros(n,n);
end