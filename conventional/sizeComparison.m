clearvars;
clc;
%% System parameter setup
lim = 100;
n = 1:1:lim;
N = 1:1:lim;
M = floor((N-1)/2);
J = N -   M;
P = 1;
% NJ = zeros(size(N));
% NP = zeros(size(N));
% for i = N
%     NJ(i) = nchoosek(N(i),J(i));
%     NP(i) = N(i);
% end
% NS = 1 + NJ + NP;
NS = (sqrt(2*pi.*N).*(N./exp(1)).^(N))./((sqrt(pi.*N).*((0.5/exp(1)).*N).^(0.5.*N)).^2);
% NSest = (sqrt((2 ./ (pi.*N)))) .* (2.^N);
% dif = NS-NSestUNS;

k = 1;

%% 2D CMO
x2d = n'*NS;
A2d = n.^2'*NS.^2;
BU2d = 2*k.*NS;
elements2d = x2d + A2d + BU2d;
byte2d = elements2d*8;
GB2d = byte2d * 1e-9;

%% 3D CMO
x3d = n'*NS;
A3d = n'.^2*NS;
F3D = n'.^2*NS;
elements3d = x3d + A3d + F3D;
byte3d = elements3d*8;
GB3d = byte3d * 1e-9;

%% SSMO
xssmo = n'*(NS);
Assmo = n'.^2*N.^2;
Bssmo = n'.^2*N;
T = n'.^2*N.*(NS);
elementsssmo = xssmo + Assmo + Bssmo + T;
bytessmo = elementsssmo*8;
GBssmo = bytessmo * 1e-9;

%% Plots
zmax = max(max(GB2d));
p2d = figure();
subplot(1,3,1)
mesh(GB2d)
set(gca, 'ZScale', 'log')
zlim([0 zmax])
xlabel('N')
ylabel('n')
zlabel('System size [GB]')
title('2D CMO')
set(gca,'ColorScale','log')

subplot(1,3,2)
mesh(GB3d)
set(gca, 'ZScale', 'log')
zlim([0 zmax])
xlabel('N')
ylabel('n')
zlabel('System size [GB]')
title('3D CMO')
set(gca,'ColorScale','log')

subplot(1,3,3)
mesh(GBssmo)
set(gca, 'ZScale', 'log')
zlim([0 zmax])
xlabel('N')
ylabel('n')
zlabel('System size [GB]')
title('SSMO')
set(gca,'ColorScale','log')

set(gcf, 'Position', [1 1 0.7 0.35].*get(0, 'Screensize'))
