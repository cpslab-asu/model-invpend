function [Kr,Ke] = buildLQGInvert(sysA,sysB,sysC,sysD)

sysH = ss(sysA,sysB,sysC,sysD);
sysG = tf(sysH);
sysp = size(sysC,1);
[sysn, sysm] = size(sysB);

sysQ = [0 0; 0 100000];

sysR = eye(sysm);

Kr = lqr(sysA, sysB, sysQ, sysR);
Bnoise = eye(sysn);
W = eye(sysn);

V = 0.01*eye(sysm);
Estss = ss(sysA, [sysB Bnoise], sysC, [0 0 0]);
[Kess,Ke] = kalman(Estss,W,V);