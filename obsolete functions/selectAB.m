function [corruptA,corruptB,uncorrupt] = selectAB(CMOstruct)
    % [corruptA,corruptB,uncorrupt] = selectAB(CMOdict) selects two sets
    % (A,B)
    % sized M out of the set 1:1:numOutputs.
    %
    % For example:
    %   - numOutputs = 12
    %     M = 5
    %       -> corruptA  = [1,2,3,4,5]
    %          corruptB  = [6,7,8,9,10]
    %          uncorrupt = [11,12]

    numOutputs = CMOstruct.numOutputs;
    M = CMOstruct.numAttackedOutputs;
    outputSet = 1:1:numOutputs;
    
    % Select the first M outputs to be in set A
    [corruptA, remainingA] = selectRandomSubset(outputSet,M);
    % Out of the remainder of the set select M outputs to be in B, the rest
    % of the signals will remain uncorrupted
    [corruptB, uncorrupt] = selectRandomSubset(remainingA,M);
    
end