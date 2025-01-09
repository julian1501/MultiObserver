function y3D = get3Dy(y,Jmo,Pmo)
    
    % Allocate memory
    y3D = zeros(Jmo.numOutputsObservers,1,Jmo.numObservers+Pmo.numObservers);
    
    % Loop over all J observers
    for j = 1:1:Jmo.numObservers
        % Select Ids of outputs
        Ids = Jmo.CiIndices(j,:);
        for k = 1:1:Jmo.numOutputsObservers
            % Select correct outputs for observer j
            y3D(k,1,j) = y(Ids(k));
        end
    end
    
    % Loop over all P observers
    for p = 1:1:Pmo.numObservers
        % Select Ids of outputs
        Ids = Pmo.CiIndices(p,:);
        for k = 1:1:Pmo.numOutputsObservers
            % Select correct outputs for observer p
            y3D(k,1,Jmo.numObservers + p) = y(Ids(k));
        end
    end

end