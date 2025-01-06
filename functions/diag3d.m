function diagMatrix = diag3d(M)
    
    % check if matrix is 3d
    size3 = size(M,3);
    if size3 < 2
        error('The input matrix has size %1f along the third dimension.',size3)
    end
    
    size1 = size(M,1);
    size2 = size(M,2);
    diagMatrix = zeros(size1*size3,size2*size3);
    for i = 1:1:size3
        slice = M(:,:,i);
        diagMatrix(size1*(i-1)+1:size1*i,size2*(i-1)+1:size2*i) = slice;
    end
end