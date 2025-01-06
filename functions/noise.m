function [v,vJ,vP,v3D,v2D] = noise(numOutputs, intensity,Jmo,Pmo)
    % doc
    v = intensity.*wgn(numOutputs,1,0);
    
    CJiIndices = Jmo.CiIndices;
    vJ = zeros(Jmo.numOutputsObservers,1,Jmo.numObservers); 
    for j = 1:1:Jmo.numObservers
        % In every j of CJ
        Cselection = CJiIndices(j,:);
        for k = 1:1:Jmo.numOutputsObservers
            % in every row k of a Cj
            % Select corresponding row of v
            CNId = Cselection(k);
            vJ(k,:,j) = v(CNId,:);
        end
    end
    
    % vP
    CPiIndices = Pmo.CiIndices;
    vP = zeros(Pmo.numOutputsObservers,1,Pmo.numObservers); 
    for j = 1:1:Pmo.numObservers
        % In every j of CJ
        Cselection = CPiIndices(j,:);
        for k = 1:1:Pmo.numOutputsObservers
            % in every row k of a Cj
            % Select corresponding row of v
            CNId = Cselection(k);
            vP(k,:,j) = v(CNId,:);
        end
    end

    % v3D
    padding = zeros(size(vJ,1)-size(vP,1),1,size(vP,3));
    vPpadded = cat(1,vP,padding);
    v3D = cat(3,vJ,vPpadded);
    v2D = cat(1,reshape(vJ,[],1,1),reshape(vP,[],1,1));

end