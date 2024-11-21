function LTilde = pad3DL(L3D,CIndices,setString,CMOstruct)
    % LTilde = pad3DL(L3D,CIndices,setString,CMOstruct) creates the 3D
    % matrix of all padded L matrices placed behind each other in the third
    % dimension.

    [numObservers, numOutputsObserver] = selectObserverSpecs(setString,CMOstruct);
    
    LTilde = zeros(CMOstruct.numOriginalStates,CMOstruct.numOutputs,numObservers);

    for c = 1:1:numObservers
        L = L3D(:,:,c);
        cIndices = CIndices(c,:);
        LTilde(:,:,c) = padL(L,cIndices,CMOstruct.numOutputs);
    end

end