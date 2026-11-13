clear all; clc; close all;

x = linspace(-15, 15, 1000);
% Crea un objeto para punto fijo: 6 bits palabra, 2 bits fracción, redondeo hacia abajo, envoltura en desborde
q = quantizer('fixed', 'floor', 'wrap', [7 2]); 
y = quantize(q, x);
figure(1)
plot(x);hold on;plot(y);hold off;