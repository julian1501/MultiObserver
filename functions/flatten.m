function flatM = flatten(M)
    
    l = size(M,3);
    h = size(M,1);
    flatM = zeros(size(M,1)*l,size(M,2));
    
    for i = 1:1:size(M,3)
        flatM(h*(i-1)+1:h*i,:) = M(:,:,i);
    end
end

