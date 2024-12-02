function COutputs = CNSetup(obj)
    % COutputs = CNSetup(sys,numOutputs) sets up the CN matrix that
    % contains all the outputs of the CMOsystem. The rows of sys.C are
    % treated as the possible outputs: if there are less then numOutputs
    % rows in sys.C duplicates are used until COutputs has numOutputs rows.
    % If there are more rows in sys.C then numOutputs the bottom rows are
    % not used.
    %
    % For example:
    %   - sys.C = [1 0; 0 1] & numOutputs = 2
    %       -> COutputs = [1 0; 0 1]
    %   - sys.C = [1 0; 0 1] & numOutputs = 3
    %       -> COutputs = [1 0; 0 1; 1 0]
    %   - sys.C = [1 0; 0 1] & numOutputs = 1
    %       -> COutputs = [1 0]
    
    % Extract the number of possible ouputs
    COptions = obj.sys.C;
    numOptions = size(COptions,1);
    
    % If the number of actual outputs (numOuputs) is smaller then the
    % number of possible outputs: take the first numOuputs rows of Coptions.
    % If the number of actual outputs (numOutputs) is larger then the
    % number of possible outputs: duplicate Coptions until there are enough
    % it has a length longer then numOutputs and trim off the bottom rows
    % untill it matches numOutputs.

    copiesRequired = ceil(obj.numOutputs/numOptions);
    % Create empty matrix to store all duplicates of the options
    COutputOptions = repmat(COptions,copiesRequired,1);
    COutputs = COutputOptions(1:obj.numOutputs,:);

end