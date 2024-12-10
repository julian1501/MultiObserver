classdef attack
    % attack represents a mechanism for simulating attacks on a system's 
    % outputs by corrupting specific signals.
    %
    % 

    properties
        numOutputs
        numAttacks
        attackList
    end

    methods
        function obj = attack(numOutputs,numAttacks)
            % attack creates an array attack
            obj.numOutputs = numOutputs;
            obj.numAttacks = numAttacks;
            if ~ (numOutputs > 2* numAttacks)
               error('The number of outputs is not larger then twice the number of attacked outputs %3.0f <= %3.0f',numOutputs,numAttackedOutputs); 
            end

            attackedOutputsA = selectAB(obj);
            fprintf('The attacked outputs are: \n')
            disp(attackedOutputsA)
            % loop over attacked outputs and add attack signal
            attackList = zeros(obj.numOutputs,1);
            for i = 1:1:obj.numAttacks
                outputA = attackedOutputsA(i);
                attackList(outputA) = 1;
            end
            obj.attackList = attackList;
        end

        function [corruptA,corruptB,uncorrupt] = selectAB(obj)
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
        
            M = obj.numAttacks;
            outputSet = 1:1:obj.numOutputs;
            
            % Select the first M outputs to be in set A
            [corruptA, remainingA] = selectRandomSubset(outputSet,M);
            % Out of the remainder of the set select M outputs to be in B, the rest
            % of the signals will remain uncorrupted
            [corruptB, uncorrupt] = selectRandomSubset(remainingA,M);
            
        end
    end
end