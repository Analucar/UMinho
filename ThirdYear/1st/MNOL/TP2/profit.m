function [f] = profit(x,a)
R = a(1)*x(1) + a(2)*x(2) + a(3)*x(3); % revenue
C = x(1)^2 + 3*(x(1)^2)*x(2)*x(3) + x(2)^2 + x(3)^2; % cost
P = R - C; % profit
f = -P; % Para prob de maximizacao
end

