clearvars; close all;

% N: number of outputs
N = 3;
% M: maximum number of corrupted outputs
M = floor((N-1)/2);

% Noiseless system definition
% sys = invPendSetup('down');
sys = dampedSpringMassSetup(0.2,5,0.5);
sysOCF = SISOtoOCF(sys);
Abar = sysOCF.A;
Bbar = sysOCF.B;
n = size(sys.A,1);
k = size(sys.B,2);
m = size(sys.C,1);

% CN is the C matrix with all N outputs
CN = CNSetup(sys,N);
% CJ is the C matrix with all (N-M) sized sets J that form an observer, so
% every (N-M) rows of CJ is a single observer
CJ = CJSetup(CN,N,M);


% Define a set e of eigenvalues from which n are randomly chosen to be the
% eigenvalues of a single entry in LJ.
eigenvalues = [-1 -2 -3 -4 -5 -6 -7 -8];
LJ = LJSetup(sys,CJ,N,eigenvalues); % TBD

% Add noise/input matrix
E = ESetup(Bbar,LJ,N);

% Create state estimates
[Astar, Bstar,Cstar] = CMOSetup(Abar,Bbar,LJ,CJ,N);
sysStar = ss(Astar,E,Cstar,0);

% simulate system
t = 0:0.05:3;
u = zeros(1,size(t,2));
eta = etaSetup(u,N,n,m,k,0.01,0);
% Initial condition is the first n elements of x0Options, xhat initial
% conditions are always 0
x0 = zeros((N+1)*n,1);
x0Options = [0.3;-0.1;-0.2;0.15;0.18;0.1;-0.25;0.2]
x0(1:n,1) = x0Options(1:n,1);

sol = lsim(sysStar,eta,t,x0)';

% Extract 'chosen' estimate from estimates throughout the simulation


% decide on what size grid should be used based on number of states in
% system
numberOfColumns = ceil(sqrt(n));
numberOfRows = ceil(n/numberOfColumns);

% create tiled plot

for l = 1:1:n
    % select subplot to edit
    subplot(numberOfRows,numberOfColumns,l)
    % rows to be plotted are l, l + j*n,...,l + j*(N+1)
    for j = 0:1:N
        rowIdToPlot = l + j*n;
        rowToPlot = sol(rowIdToPlot,:);
        p = plot(t,rowToPlot);
        hold on
        if j == 0
            p.LineWidth = 2;
        elseif j > 0
            p.LineStyle = '--';
        end
        hold on
    end
    title(strcat('x',num2str(l)))

end



