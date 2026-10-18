% ------------------------------------------------------------
% Práctica: Ruido intrínseco y mediado de señal
% ------------------------------------------------------------
% Este script calcula y dibuja las curvas Vn1(f), Vn2(f) y VnT(f)
% en un mismo diagrama tipo Bode (escala logarítmica)
% ------------------------------------------------------------

clear; clc; close all;

% --------------------------
% Parámetros del circuito
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
Vn1 = 3.81 .* HL .* HA;              % Ruido plano (mV/√Hz)
Vn2 = (96.6 ./ sqrt(f)) .* HL .* HA; % Ruido 1/f (mV/√Hz)
VnT = sqrt(Vn1.^2 + Vn2.^2);         % Ruido total

% --------------------------
% Gráfica diagrama de Bode
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


% 1. Calcular integral de VnT^2(f) desde 0.1 Hz hasta 1 MHz
% ------------------------------------------------------------
integrando = @(f) (VnT(f)/1000).^2;   % pasar a V^2/Hz antes de integrar
fmin = 0.1; 
fmax = 1e6;

% Integración adaptativa
integral_V2 = integral(integrando, fmin, fmax, 'ArrayValued', true);

% Raíz cuadrada del resultado → ruido RMS total
VNT_total_V = sqrt(integral_V2);
VNT_total_mV = VNT_total_V * 1000;

fprintf('\nValor eficaz total del ruido (0.1 Hz a 1 MHz): %.3f mV RMS\n', VNT_total_mV);

% --------------------------
% Gráfica del ruido acumulado VNT(F)
% ------------------------------------------------------------
F=logspace(1,6,10000);
VNT_F = zeros(size(F));

for k = 1:length(F)
    VNT_F(k) = sqrt(integral(@(f)(VnT(f)/1000).^2, fmin, F(k), 'ArrayValued', true)) * 1000;
end

figure(2);
semilogx(F, VNT_F, 'LineWidth', 2, 'Color', [0 0.3 0.6]);
grid on;
xlabel('Frecuencia superior de integración F [Hz]');
ylabel('Ruido eficaz total hasta F [mV RMS]');
title('Ruido total acumulado V_{NT}(F) usando integral()');
