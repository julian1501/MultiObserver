clearvars;
clc;
% close all;

%% System parameter setup
m = 50;
k = 1;
st = 1;

n = 1:st:m;
N = 1:st:m;

lim = size(N,2);

size2d   = zeros(lim);
size3d   = zeros(lim);
sizessmo = zeros(lim);

%% size calculations
for i = 1:1:lim
    for j = 1:1:lim
        M = floor((N(j)-1)/2);
        J = N(j)-M;
        P = 1;
        
        NJ = nchoosek(N(j),J);
        NP = nchoosek(N(j),P);

        NS = NJ+NP;
        
        size2d(i,j) = n(i)*NS + (n(i)^2)*(NS^2) + n(i)*k*NS + k;
        size3d(i,j) = n(i)*NS + (n(i)^2)*NS + (n(i)^2)*NS;
        sizessmo(i,j) = n(i)*NS + (n(i)^2)*(N(j)^2) + (n(i)^2)*N(j) + (n(i)^2)*N(j)*NS;
    end
end

GB(:,:,1) = log10(size2d.*1e-9);
GB(:,:,2) = log10(size3d.*1e-9);
GB(:,:,3) = log10(sizessmo.*1e-9);


%% Plots
zmax = max(max(GB(:,:,1)));

tcl = tiledlayout(1,3);

for i = 1:1:3
    nexttile()
    s = pcolor(N,n,GB(:,:,i));
    s.EdgeColor = 'none';
    xlabel('N')
    ylabel('n')
    title('2D CMO')
    clim([-10 zmax])
end

cb = colorbar(); 
cb.Layout.Tile = 'east'; % Assign colorbar location
set(gcf, 'Position', [1 1 0.4 0.2].*get(0, 'Screensize'))

dif = (sizessmo - size3d)*1e-9;
rat = sizessmo./size3d;

