function attack = attackFunction(t,a)

    aFlat = a(:);
    attackFlat = zeros(size(aFlat));
    for i = 1:1:size(aFlat,1)
        if aFlat(i) == 1
            % Edit function below for changing the attack function
            attackFlat(i) = exp(10*t);
        elseif aFlat(i) == 2
            attackFlat(i) = sin(t);
        end    
    end
    attack = reshape(aFlat,size(a));
end