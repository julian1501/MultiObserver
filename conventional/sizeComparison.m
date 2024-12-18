clearvars;
clc;
close all;

%% System parameter setup
lim = 50;
k = 1;

size2d   = zeros(lim);
size3d   = zeros(lim);
sizessmo = zeros(lim);

%% size calculations
for N = 1:1:lim
    for n = 1:1:lim
        M = floor((N-1)/2);
        J = N-M;
        P = 1;
        
        NJ = nchoosek(N,J);
        NP = nchoosek(N,P);

        NS = NJ+NP;
        
        size2d(n,N) = n*NS + (n^2)*(NS^2) + 2*k*NS;
        size3d(n,N) = n*NS + (n^2)*NS + (n^2)*NS;
        sizessmo(n,N) = n*NS + (n^2)*(N^2) + (n^2)*N + (n^2)*N*NS;
    end
end

GB(:,:,1) = log10(size2d.*1e-9);
GB(:,:,2) = log10(size3d.*1e-9);
GB(:,:,3) = log10(sizessmo.*1e-9);



n = 1:1:lim;
N = 1:1:lim;

%% Plots
zmax = max(max(GB(:,:,1)));

tcl = tiledlayout(1,3);

for i = 1:1:3
    nexttile()
    mesh(N,n,GB(:,:,i))
    zlim([-10 zmax])
    clim([0 zmax])
    xlabel('N')
    ylabel('n')
    zlabel('System size [GB]')
    title('2D CMO')
    set(gca,'ztick',[-10 0 10 20]);
    set(gca,'zticklabel',{'10^{-10}' '10^{0}' '10^{10}' '10^{20}'})
end

% nexttile()
% mesh(N,n,GB3d)
% set(gca, 'ZScale', 'log')
% zlim([0 zmax])
% clim([0 zmax])
% xlabel('N')
% ylabel('n')
% zlabel('System size [GB]')
% title('3D CMO')
% set(gca,'ColorScale','log')
% set(gca,'ztick',[10^0 10^10 10^20 10^60]);
% set(gca,'zticklabel',{'10^{0}' '10^{10}' '10^{20}' '10^{60}'})
% 
% nexttile()
% mesh(N,n,GBssmo)
% set(gca, 'ZScale', 'log')
% zlim([0 zmax])
% clim([0 zmax])
% xlabel('N')
% ylabel('n')
% zlabel('System size [GB]')
% title('SSMO')
% set(gca,'ColorScale','log')
% set(gca,'ztick',[10^0 10^20 10^40 10^60]);
% set(gca,'zticklabel',{'10^{0}' '10^{20}' '10^{40}' '10^{60}'})

cb = colorbar(); 
cb.Layout.Tile = 'east'; % Assign colorbar location
set(gcf, 'Position', [1 1 0.7 0.35].*get(0, 'Screensize'))
