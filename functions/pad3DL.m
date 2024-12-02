function Lpadded = pad3DL(mo)
    % LTilde = pad3DL(L3D,CIndices,setString,CMOstruct) creates the 3D
    % matrix of all padded L matrices placed behind each other in the third
    % dimension.
    
    Lpadded = zeros(mo.nx,mo.numOutputs,mo.numObservers);

    for c = 1:1:mo.numObservers
        L = mo.Li(:,:,c);
        cIndices = mo.CiIndices(c,:);
        Lpadded(:,:,c) = padL(L,cIndices,mo.numOutputs);
    end

end