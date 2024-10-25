clearvars; close all;

% N: number of outputs
N = 12;
% M: number of corrupted outputs
M = 5;

% System definition
sys = invPendSetup('down');
% CJ is the bank of observers; each row is an observer
CJ = CJSetup(sys,N,M);

