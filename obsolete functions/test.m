m = 20;
a = zeros(m,1);
b = zeros(m,1);
for n = 1:1:m
    a(n) = factorial(n);
    b(n) = stirling(n);
end
e = a - b;