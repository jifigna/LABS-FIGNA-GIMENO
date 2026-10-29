

function [P, Pref] = generar_puntos(N, sigma)
% P: puntos observados N x 2. Pref: contorno de referencia.
% Coordenadas de orden unidad para centrar la practica en la SVD.
t = (0:N-1)' * 2*pi/N;
phi = pi/6;
R = [cos(phi), -sin(phi); sin(phi), cos(phi)];
centro = [0.3, -0.2];
P0 = [2*cos(t), sin(t)] * R' + centro;
P = P0 + sigma*randn(N,2);
tr = linspace(0,2*pi,500)';
Pref = [2*cos(tr), sin(tr)] * R' + centro;
end