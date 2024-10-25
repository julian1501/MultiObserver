clearvars; close all;

% N: number of outputs
N = 8;
% M: maximum number of corrupted outputs
M = floor((N-1)/2);

% Noiseless system definition
sys = invPendSetup('down');
A = sys.A;
B = sys.B;
% CJ is the bank of observers; each row is an observer
CJ = CJSetup(sys,N,M);
LJ = 0; % TBD

% Add noise
... % TBD

% Create state estimates
[Astar, Bstar,Cstar] = CMOSetup(A,B,[1;1;1;1],CJ,N);
Osys = ss(Astar,Bstar,Cstar,0);