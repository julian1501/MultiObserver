function attack = getAttackValue(t,a,attackFunction,CMOstruct)

    aFlat = a(:);
    for i = 1:1:size(aFlat,1)
        if aFlat(i) ~= 0
            aFlat(i) = double(attackFunction(t));
        end    
    end
    attack = reshape(aFlat,size(a));
end