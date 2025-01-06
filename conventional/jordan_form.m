% This code simulates the response of system matrix A on tspan by
% caluclating the Jordan normal form and calculating x at each timestep in
% tspan. It then plots the result in a tiledplot.
close all; clearvars;
tspan = 0:0.01:5;
x0 = [0.3;-0.1;0.5;0.2];

A = [0 1 0 0; -15 -2 15 2; 0 0 0 1; 0 0 -15 -2];
[P,J] = jordan(A);
invP = inv(P);

x = zeros(4,size(tspan,2));
for t = 1:1:size(tspan,2)
    x(:,t) = P*expm(tspan(t)*J)*invP*x0;
end

fig = tiledlayout('flow');
sgtitle("2 mass-spring-damper")

for l = 1:1:4
    nexttile
    plot(tspan,x(l,:),LineWidth=2,Color='black')
    xlabel('Time')
    mass = floor((l+1)/2);

    if (-1)^l == -1
        % odd
        ylabel('Position')
        title(['Position of mass ' num2str(mass)])
    else
        % even
        ylabel('Velocity')
        title(['Velocity of mass ' num2str(mass)])
    end
    
    ylim([-1.5 1.5]);
    grid on;

end

set(gcf, 'Position', 0.4*get(0, 'Screensize'));
hold on;