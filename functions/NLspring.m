function NLk = NLspring(sys,y)
% NLspring Function
%
% The 'NLspring' function calculates the nonlinear spring force based on a 
% hardening spring model. It computes the force for each spring in the system 
% based on the displacement (y) of the masses and the parameters of the system 
% such as spring constant (k), mass (m), and nonlinear factor (a). The function 
% is used when the system has nonlinearities (i.e., when 'NLsize > 0').
%
% Documentation written by ChatGPT.
%
% Inputs:
% -------
% - 'sys': A mass-spring-damper system object that contains the properties 
%   defining the system, including spring constants (k), mass (m), nonlinear 
%   size (NLsize), and the nonlinear factor (a).
% - 'y': A vector of displacements of the masses in the system.
%
% Outputs:
% --------
% - 'NLk': A vector containing the nonlinear spring forces for each mass. 
%   If the system has no nonlinearities (i.e., 'sys.NLsize == 0'), the output 
%   is an empty array.
%
% Function Description:
% ---------------------
% The function calculates the nonlinear spring force for each spring in the 
% system based on the displacement from the previous spring and the system's 
% properties. The nonlinear spring force is determined by the formula:
% 
%     NLk = (k * a^2 * d^3) / m
%
% where:
% - 'k' is the spring constant,
% - 'a' is the nonlinear factor,
% - 'd' is the displacement difference between the current and previous masses, 
%   and
% - 'm' is the mass.
%
% If the system does not have nonlinearities (i.e., 'sys.NLsize == 0'), 
% the function returns an empty array.
%
% Initialization Steps:
% ---------------------
% - The function first checks if the system has nonlinearities by examining 
%   'sys.NLsize'. If no nonlinearities are present, it returns an empty array.
% - If nonlinearities exist, it initializes a zero vector 'NLk' to store 
%   the nonlinear spring forces.
% - The function iterates through each mass, calculating the displacement 
%   difference ('d') between the current mass and the previous one, and 
%   computes the corresponding nonlinear spring force using the specified formula.
%
% Example:
% --------
% To calculate the nonlinear spring forces for a given system:
% 
% sys = msd(true, 2, [1; 1], [10; 10], [0.5; 0.5]);  % A system object
% y = [0.2; 0.3];  % Displacements of the masses
% NLk = NLspring(sys, y);
%
% This will compute the nonlinear spring forces for the 2-mass system with 
% specified displacements.
%
% Notes:
% ------
% - This function applies a nonlinear hardening spring model. The spring force 
%   is cubic with respect to the displacement difference between successive masses.
% - The function handles both systems with and without nonlinearities, providing 
%   flexibility in the modeling of different systems.
% - If the system has no nonlinearities, it returns an empty array, indicating 
%   that no nonlinear forces need to be computed.
%
% See also:
% ---------
% msd, multiObserverODE

    if sys.NLsize == 0
        NLk = [];
    else
        NLk = zeros(sys.NLsize,1);
        dPrev = 0;
        for j = 1:1:sys.NLsize
            d = y(j) - dPrev;
            dPrev = dPrev + d;
            NLk(j) = (sys.k*sys.a^2*d^3)/sys.m;
        end

    end

end