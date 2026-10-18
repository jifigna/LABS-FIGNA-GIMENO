% ------------------------------------------------------------
% Práctica: Ruido intrínseco y mediado de señal
% ------------------------------------------------------------
% Este script calcula y dibuja las curvas Vn1(f), Vn2(f) y VnT(f)
% en un mismo diagrama tipo Bode (escala logarítmica).
% Además calcula el ruido total en función de la frecuencia.
% ------------------------------------------------------------

clear; clc; close all;

% --------------------------
% Frecuencias de corte
% --------------------------
fcL = 98700;     % Frecuencia de corte de cada etapa pasobajo (Hz)
fci = 146;       % Frecuencia de corte inferior principal (Hz)
fch = 24;        % Frecuencia de corte inferior secundaria (Hz)

% Vector de frecuencias (logarítmico)
f = logspace(1,6,10000);   % de 10 Hz a 1 MHz

% --------------------------
% Funciones de transferencia
% --------------------------
% Paso bajo combinado de dos etapas (U4 y U5)
HL = 1 ./ sqrt( (1 + (f/fcL).^2) .* (1 + (f/fcL).^2) );

% Paso alto combinado (fci y fch)
HA = sqrt( ((f/fci).^2 ./ (1 + (f/fci).^2)) .* ((f/fch).^2 ./ (1 + (f/fch).^2)) );

% --------------------------
% Densidades espectrales de ruido
% --------------------------
Vn1 = 3.794 .* HL .* HA;              % Ruido plano (mV/√Hz)
Vn2 = (91.77 ./ sqrt(f)) .* HL .* HA; % Ruido 1/f (mV/√Hz)
VnT = sqrt(Vn1.^2 + Vn2.^2);         % Ruido total

% --------------------------
% Gráfica diagrama de Bode de la densidad espectral de ruido
% --------------------------
figure(1);
semilogx(f, Vn1, 'r', 'LineWidth', 1.5); hold on;
semilogx(f, Vn2, 'b--', 'LineWidth', 1.5);
semilogx(f, VnT, 'k--', 'LineWidth', 2);
grid on;
xlabel('Frecuencia (Hz)');
ylabel('Densidad espectral [mV/√Hz]');
title('Densidad espectral de ruido');
legend('Aportación plana Vn1(f)', 'Aportación 1/f Vn2(f)', 'Total VnT(f)', 'Location','SouthEast');

% ------------------------------------------------------------
% Integración del ruido total
% ------------------------------------------------------------

% Límites de integración
fmin = 0.1; 
fmax = 1e6;

% Función para VnT (en mV/√Hz)
VnT_fun = @(x) sqrt( (3.81 .* (1 ./ sqrt( (1 + (x/fcL).^2) .* (1 + (x/fcL).^2) ))...
    .* sqrt( ((x/fci).^2 ./ (1 + (x/fci).^2)) .* ((x/fch).^2 ./ (1 + (x/fch).^2)) ) ).^2 + ...
    ((96.6 ./ sqrt(x)) .* (1 ./ sqrt( (1 + (x/fcL).^2) .* (1 + (x/fcL).^2) )) ...
    .* sqrt( ((x/fci).^2 ./ (1 + (x/fci).^2)) .* ((x/fch).^2 ./ (1 + (x/fch).^2)) ) ).^2 );

% Integral de VnT^2 entre 0.1 Hz y 1 MHz
integrando = @(x) (VnT_fun(x)).^2;
integral_V2 = integral(integrando, fmin, fmax);

% Valor eficaz total del ruido (RMS)
VNT_total_mV = sqrt(integral_V2);


% ------------------------------------------------------------
% Cálculo y gráfica del ruido acumulado VNT(F)
% ------------------------------------------------------------
integral_acum = cumtrapz(f, VnT_fun(f).^2);  % Integral acumulada (V^2)
VNT_F = sqrt(integral_acum);        % Pasar a mV RMS

figure(2);
semilogx(f, VNT_F, 'b', 'LineWidth', 2); hold on;
grid on;
xlabel('Frecuencia F [Hz]');
ylabel('Ruido eficaz acumulado [mV RMS]');
title('Ruido total acumulado V_{NT}(F)');
legend('VNT(F)','Ubicación de fc_{total}','Ruido total integrado','Location','SouthEast');
