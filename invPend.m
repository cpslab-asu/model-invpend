%% Inverted pendulum 
function [thetaY, thetaDot,timeOut] = invPend(X,UT)

m = 1;
L = 1;
b = 0.01;
g = 9.83;
timeSample = 0.001;
theta(1) = X(1);
theta_dot(1) = X(2);

Gain1 = b/(m*L^2);
for k = 2:10000
    theta(k) = theta(k-1) + timeSample*theta_dot(k-1);
    theta_dot(k) = theta_dot(k-1) + timeSample*((g/L)*sin(theta(k-1))-(b/(m*L^2))*theta_dot(k-1));
end
%figure
%plot(theta)
%hold on
%plot(theta_dot,'r')


%% Linearization about initial point

A = [0 1; cos(theta(1)) -b/(m*L^2)];
B = [0 1/(m*L^2)]';
C = [0 1];
D = 0;

[Kr,Ke] = buildLQGInvert(A, B, C, D);

modelInv = 'InvertedPend';

load_system(modelInv);

set_param('InvertedPend/InvPend/theta','InitialCondition',num2str(theta(1)));
set_param('InvertedPend/InvPend/Gain1','Gain',num2str(Gain1));
set_param('InvertedPend/InvPend/Gain2','Gain',num2str(Gain1));


set_param('InvertedPend/InvPend/theta_dot','InitialCondition',num2str(theta(2)));


simOut = sim(modelInv);

thetaY = simOut.theta;
thetaDot = simOut.theta_dot;
timeOut = simOut.tout;

%close_system('InvertedPend.slx',0)

