function [system,sysName,A,B,C,D] = xDampedSpringMassSetup(x,m,k,c)
    % This function sets up a damped mass spring system.
    sysName = strcat(num2str(x), " mass-spring-damper");
    
    if x == 1
        A = [0, 1; -k(1)/m(1), -c(1)/m(1)];
        B = [0; 1/m(1)];
        % C should contain all rows that are valid outputs all rows should
        % individu
        C = [1 0;
             0 1];
        D = 0;
    elseif x == 2
        A = zeros(2*x);
        
        % Add state matrix entries for the first mass
        A(1,2) = 1;
        A(2,1:4) = [-(k(1)+k(2))/m(1), -(c(1)+c(2))/m(1), k(2)/m(1), c(2)/m(1)];
    
        % Add state matrix entries for the last mass
        A(end-1,end) = 1;
        A(end,end-3:end) = [k(end)/m(end) c(end)/m(end) -k(end)/m(end) -c(end)/m(end)];
        
        % Add state matrix entries for intermediate matrices
        for i = 2:1:x-1
            A(2*i-1,2*i) = 1;
            slice = [k(i) c(i) -(k(i)+k(i+1))/m(i), -(c(i)+c(i+1))/m(i), k(i+1)/m(i), c(i+1)/m(i)];
            A(2*i,2*i-3:2*i+2) = slice;
        end
        
        % Set up B
        B = zeros(2*x,x);
        for i = 1:1:x
            B(2*i,i) = 1/m(i);
        end
    
    
        % C should contain all rows that are valid outputs
        C = zeros(x,2*x);
        for i = 1:1:x
            C(i,1:2*i) = repmat([1 0],1,i);
        end
    end
    system = ss(A,B,C,0);

end