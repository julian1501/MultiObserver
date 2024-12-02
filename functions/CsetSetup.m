function [Cset,CsetIndices,setAttack] = CsetSetup(CN,Attack,obj)
    % [Cset, CsetIndices] =
    % CsetSetup(CN,sizeObserver,numOutputs,numObservers) sets up a 3D array
    % with all observers with outputs a subset of CN. The cardinality of
    % this subset is sizeObserver and numObservers indicates the amount of
    % subsets that are made. CsetIndices is a matrix where each row stored
    % the indices of the observers that make up a subset.
    %
    % For example:
    %   - CN = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1] 
    %     attack = [1 0 1 0];
    %     numObservers = 4 & numOutputsObserver = 3
    %       -> Cset(:,:,1) = [1 0 0 0;
    %                         0 1 0 0;
    %                         0 0 1 0];
    %          Cset(:,:,2) = [1 0 0 0;
    %                         0 1 0 0;
    %                         0 0 0 1];
    %          Cset(:,:,3) = [1 0 0 0;
    %                         0 0 1 0;
    %                         0 0 0 1];
    %          Cset(:,:,4) = [0 1 0 0;
    %                         0 0 1 0;
    %                         0 0 0 1];
    %       -> CsetIndices = [1 2 3; 1 2 4; 1 3 4; 2 3 4];
    %       -> setAttack(:,:,1) = [1; 0; 1];
    %          setAttack(:,:,2) = [1; 0; 0];
    %          setAttack(:,:,1) = [1; 1; 0];
    %          setAttack(:,:,1) = [0; 1; 0];
    

    % Extract the number of states
    numStates = obj.sys.nx;

    % Define a list with all indices, so 1,2,...,N
    outputList = 1:1:obj.numOutputs;
    
    % Select the indices of the combinations of Cj's
    CsetIndices = nchoosek(outputList,obj.numOutputsObservers);
    
    % Loop over the combinations and add them to the empty CJ
    Cset = zeros(obj.numOutputsObservers,numStates,obj.numObservers);
    setAttack = zeros(obj.numOutputsObservers,1,obj.numObservers);
    for j = 1:1:obj.numObservers
        % In every j of CJ
        Cselection = CsetIndices(j,:);
        for k = 1:1:obj.numOutputsObservers
            % in every row k of a Cj
            % Select first row of Cj
            CNId = Cselection(k);
            Cset(k,:,j) = CN(CNId,:);
            setAttack(k,:,j) = Attack.attackList(CNId,:);
        end

    end

end