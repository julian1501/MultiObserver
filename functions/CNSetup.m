function COutputs = CNSetup(sys,numOutputs)
    % This function sets up the CN vector, which contains all N outputs
    % of the system. All rows are an output.
    % LTI system sys; number of outputs N; number of corrupted outputs M.
    
    % Extract the number of possible ouputs
    COptions = sys.C;
    numOptions = size(COptions,1);
    
    % If the number of actual outputs (numOuputs) is smaller then the
    % number of possible outputs: take the first numOuputs rows of Coptions.
    % If the number of actual outputs (numOutputs) is larger then the
    % number of possible outputs: duplicate Coptions until there are enough
    % it has a length longer then numOutputs and trim off the bottom rows
    % untill it matches numOutputs.

    copiesRequired = ceil(numOutputs/numOptions);
    % Create empty matrix to store all duplicates of the options
    COutputOptions = repmat(COptions,copiesRequired,1);
    COutputs = COutputOptions(1:numOutputs,:);

end