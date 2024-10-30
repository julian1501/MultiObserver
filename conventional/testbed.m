close all;
A = [0 1 0 0; -2 -2 1 1; 0 0 0 1; 2 2 -2 -2];
B = [0;0;0;1];
C = [1 0 0 0; 0 0 1 0];
D = [0;0;0;0];
if ~ isMatrixStable(A)
    error('A not stable')
end
s = ss(A,B,eye(4),D);
sBar = MIMOtoOCF(s);
tf(s)
tf(sBar)

t = 0:0.01:5;
u = zeros(1,size(t,2));

ssol = lsim(s,u,t,[0.5;0;0.5;0]);
sBarsol = lsim(sBar,u,t,[0.5;0;0.5;0;0;0;0;0;0;0;0;0;0;0;0;0]);

fig = figure();
sgtitle({'Double spring mass damper system','Standard form to OCF comparison'})
for l =1:1:4
    subplot(2,2,l)
    plot(t,ssol(:,l),Color='blue');
    hold on;
    plot(t,sBarsol(:,l),Color='red')
    if l == 1
        legend({'Standard form','OCF'},'Location','southeast')
    end
    xlabel('Time')
    ylabel('Position')
    grid on
    title(['x' num2str(l)])
end