function difflist = sbeNorm(xj,xP3D,numObservers,numOfPsubsetsInJList,pSubsetOfjIndices)
    
    difflist = zeros(numObservers,1,'like',xj);
    for p = numOfPsubsetsInJList
        pId = pSubsetOfjIndices(p);
        difflist(p) = norm(xj-xP3D(:,:,pId));
    end

end