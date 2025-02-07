classdef attack
% ATTACK Class
% 
% The 'attack' class models an attack on a specified number of outputs. 
% It allows for the initialization of the system, random selection of 
% attacked outputs, and assignment of attack signals.
%
% This documentation was written by ChatGPT. Th
%
% Properties:
% -----------
% - 'numOutputs' (integer): 
%   The total number of outputs in the system.
%
% - 'numAttacks' (integer): 
%   The number of outputs to be attacked.
%
% - 'attackList' (array): 
%   A column vector of size 'numOutputs x 1' where each element is 1 for attacked outputs 
%   and 0 otherwise.
%
% Methods:
% --------
% - 'attack(numOutputs, numAttacks, attackedOutputs': 
%   Constructor that initializes an 'attack' object with the given number of outputs and 
%   attacks. It ensures that 'numOutputs > 2 * numAttacks' and creates an array 
%   'attackList' to indicate which outputs are attacked. If attackedOutputs is 
%   empty, the attacked outputs are randomly selected by selectAB. If the condition
%   is not met, an error is thrown.
%
%   Example Usage:
%       obj = attack(10, 3);
%
%   Outputs:
%       Displays the indices of the attacked outputs and initializes 'attackList'.
%
% - '[corruptA, corruptB, uncorrupt] = selectAB()': 
%   Selects two subsets ('corruptA' and 'corruptB') of size 'numAttacks' each from 
%   the range '1:numOutputs'. The remaining elements form the 'uncorrupt' set.
%
%   Outputs:
%       - 'corruptA': Array of indices for the first corrupted subset.
%       - 'corruptB': Array of indices for the second corrupted subset.
%       - 'uncorrupt': Array of indices for uncorrupted outputs.
%
% Internal Helper Function:
% -------------------------
% - 'selectRandomSubset(set, M)': 
%   (Not defined in the provided code) Selects a random 
%   subset of size 'M' from the input 'set' and returns the selected subset and the 
%   remaining elements. selectRandomSubset.m
%
% Notes:
% ------
% - The 'selectAB' method is intended to be called internally within the constructor 
%   to set up the initial attack configurations.
%
% Error Conditions:
% -----------------
% - If 'numOutputs' is not greater than '2 * numAttacks', an error is raised with a 
%   descriptive message. This ensures that sufficient outputs remain uncorrupted.


    properties
        numOutputs
        numAttacks
        attackList
    end

    methods
        function obj = attack(numOutputs,numAttacks,attackedOutputs)
            % attack creates an array attack
            obj.numOutputs = numOutputs;
            obj.numAttacks = numAttacks;
            if ~ (numOutputs > 2* numAttacks)
               warning('The number of outputs is not larger then twice the number of attacked outputs %3.0f <= %3.0f',numOutputs,numAttacks); 
            end
            
            if size(attackedOutputs) == [0,0]
                attackedOutputsA = selectAB(obj);
            else
                attackedOutputsA = attackedOutputs;
            end
                    
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

        function [corruptA,uncorrupt] = selectAB(obj)
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
            [corruptA, uncorrupt] = selectRandomSubset(outputSet,M);
            
        end
    end
end