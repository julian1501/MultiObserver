function attack = attackFunction(t,a)

    aFlat = a(:);
    attackFlat = zeros(size(aFlat));
    for i = 1:1:size(aFlat,1)
        if aFlat(i) ~= 0
            % Edit function below for changing the attack function
            attackFlat(i) = exp(t);
        end    
    end
    attack = reshape(aFlat,size(a));
end