clearvars; close all;
fprintf('\n')
% N: number of outputs
N = 10;
fprintf('The number of outputs is %3.0f: \n',N)
% M: maximum number of corrupted outputs
M = floor((N-1)/2);
fprintf('The maximum allowable number of compromised outputs %3.0f: \n',M)
J = N-M;
fprintf('The size of each observer is: %3.0f \n',J)
numObservers = nchoosek(N,J);
fprintf('The number of observers is: %3.0f \n',numObservers)


% Noiseless system definition
sys = dampedSpringMassSetup(0.2,5,0.5,J);
% sys = doubleDampedSpringMassSetup(0.3,0.2,6,7,0.5,0.5,J);
A = sys.A;
B = sys.B;
if isMatrixStable(A)
    fprintf('The system is internally stable. \n')
else
    fprintf('The system is internally unstable. \n')
end
sysOCF = MIMOtoOCF(sys);
Abar = sysOCF.A;
Bbar = sysOCF.B;
Dbar = sysOCF.D;
n = size(sys.A,1);
k = size(sys.B,2);
m = size(sys.C,1);

% CN is the C matrix with all N outputs
CN = CNSetup(sys,N);
% CJ is the C matrix with all (N-M) sized sets J that form an observer, so
% every (N-M) rows of CJ is a single observer
CJ = CJSetup(CN,J,N,numObservers);
% AJ = AJSetup(CJ,J)


% Define a set e of eigenvalues from which n are randomly chosen to be the
% eigenvalues of a single entry in LJ.
eigenvalues = [-1 -2 -3 -4 -5 -6 -7 -8];
[AJ,BJ,CJ,~,LJ] = systemJSetup(A,B,CJ,Dbar,numObservers,J,eigenvalues); % TBD

% Create state estimates
[Astar, Bstar,Cstar] = systemStarSetup(Abar,Bbar,AJ,BJ,LJ,CJ,J,numObservers);

% Add noise/input matrix
E = ESetup(Bstar,LJ,numObservers,J*n);

% Create system combining noise and state estimators
sysStar = ss(Astar,E,Cstar,0);



% simulate system
t = 0:0.01:5;
u = zeros(k,size(t,2));
eta = etaSetup(u,numObservers,n,m,0.01,0);
% Initial condition is the first n elements of x0Options, xhat initial
% conditions are always 0
x0 = zeros((numObservers+1)*n*m,1);
x0Options = [0.3;-0.1;-0.2;0.15;0.18;0.1;-0.25;0.2];
x0(1:m,1) = x0Options(1:m,1);

sol = lsim(sysStar,eta,t,x0)';

% Extract 'chosen' estimate from estimates throughout the simulation

%% Plots
% decide on what size grid should be used based on number of states in
% system
numberOfColumns = ceil(sqrt(n));
numberOfRows = ceil(n/numberOfColumns);

% create tiled plot
for l = 1:1:n
    % select subplot to edit
    fig = subplot(numberOfRows,numberOfColumns,l);
    % rows to be plotted are l, l + j*n,...,l + j*(N+1)
    for j = 0:1:numObservers
        rowIdToPlot = l + j*n*m;
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

set(gcf, 'Position', 0.9*get(0, 'Screensize'));

