function attackVector = attackFunction(t,a)
% ATTACKFUNCTION
%
% The 'attackFunction' generates an attack vector based on a given time ('t') and 
% an attack configuration array ('a'). The function allows different attack signals 
% to be applied based on the value of elements in 'a'. When 'a' is applied
% in the 3D-CMO context the 3D attack configuration array is first
% flattened and then reshaped.
%
% This documentation was written by ChatGPT.
%
% Syntax:
% -------
% 'attackVector = attackFunction(t, a)'
%
% Inputs:
% -------
% - 't' (numeric): 
%   The current time or scalar value used for generating the attack signals.
%
% - 'a' (array): 
%   A matrix or array where each element represents the attack configuration for 
%   the corresponding output:
%     - '1': Linear attack, returns the time 't'.
%     - '2': Sinusoidal attack, returns 'sin(t)'.
%     - Any other value: No attack, returns '0'.
%
% Outputs:
% --------
% - 'attackVector' (array): 
%   An array of the same size as 'a', where each element corresponds to the attack signal 
%   generated based on the configuration in 'a':
%     - If 'a(i) == 1', 'attackVector(i) = t'.
%     - If 'a(i) == 2', 'attackVector(i) = sin(t)'.
%     - Otherwise, 'attackVector(i) = 0'.
%
% Example Usage:
% --------------
% Given an attack configuration matrix 'a' and a time 't':
% t = 2;
% a = [1; 0; 2; 2; 1; 0];
% attackVector = attackFunction(t, a);
%
% The resulting 'attackVector' will be:
% attackVector =
%      [2.0000; 0; 0.9093; 0.9093; 2.0000; 0];
%
% Notes:
% ------
% - Users can customize the attack logic by modifying the 'if-elseif' block for 
%   different attack functions.

    
    aFlat = a(:);
    attackFlat = zeros(size(aFlat));
    for i = 1:1:size(aFlat,1)
        if aFlat(i) == 1
            % Edit function below for changing the attack function
            attackFlat(i) = sin(t);
        elseif aFlat(i) == 2
            attackFlat(i) = sin(t);
        end    
    end
    attackVector = reshape(attackFlat,size(a));
end