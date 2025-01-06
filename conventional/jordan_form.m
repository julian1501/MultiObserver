tspan = 0:0.01:5;
x0 = [0.3;-0.1;0.5;0.2];

A = [0 -1 0 0; -15 -2 15 2; 0 0 0 1; 0 0 -15 -2];
[P,J] = jordan(A);

x = zeros(size(tspan,2));
for t = 1:1:size(tspan,2)
    x(t) = inv(P)*exp(tspan(t)*J)*P*x0;
end

MOplot()