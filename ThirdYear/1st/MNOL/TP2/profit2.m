function [f] = profit2(x)
R = 2*x(1) + 3*x(2) + 3.2*x(3); % revenue
C = x(1)^2 + 3*(x(1)^2)*x(2)*x(3) + x(2)^2 + x(3)^2; % cost
P = R - C; % profit
f = -P; % Para prob de maximizacao
end
