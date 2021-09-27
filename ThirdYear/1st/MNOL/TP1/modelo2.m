function [ m ] = modelo2(c,x)
%c coeficientes do modelo
%x sao os dados 
m = c(1).*exp(x./96)+c(2)*3*sin(x)+c(3)*2*x.^2; 
end


