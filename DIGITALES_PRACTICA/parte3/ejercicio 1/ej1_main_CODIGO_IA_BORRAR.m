% ========================================================================
%  ej1_main.m  -  Unit 3 lab, Ejercicio 1
%  Arquitectura en punto fijo de una FFT de 512 puntos (62,5 MHz)
%  Basado en fftmain.m (Parte1/sources/matlab)
% =========================================================================
clear; close all; clc;

% Rutas: se cargan las fuentes de Parte1 (FlexFFT, FlexBtfly, genInput)
%  con addpath, sin copiarlas a esta carpeta
ruta_ej1 = fileparts(mfilename('fullpath'));
if isempty(ruta_ej1), ruta_ej1 = pwd; end
ruta_src = fullfile(ruta_ej1, '..', '..', 'Parte1', 'sources', 'matlab');
if ~exist(fullfile(ruta_src, 'FlexFFT.m'), 'file')
    error('No encuentro las fuentes de Parte1 en: %s', ruta_src);
end
addpath(ruta_src);
cd(ruta_ej1);          % W_coef.h y las figuras se generan en esta carpeta

% 0) Parametros
fs        = 62.5e6;              % frecuencia de muestreo/reloj [Hz]
Nfft      = 512;                 % puntos de la FFT
Nstage    = log2(Nfft);          % 9 etapas
Bin       = 12;                  % bits de la entrada
Nframes   = 20;                  % 1 trama de tonos + 19 de ruido
tones     = [2e6 5e6 9e6 12e6];  % mismos tonos que fftmain.m
amplitude = 0.5;

qin  = quantizer('fixed', 'round', 'saturate', [Bin Bin-1]);   % [12,11]
sqnr = @(ref, y) 10*log10(sum(abs(ref(:)).^2) / sum(abs(ref(:) - y(:)).^2));

% 1) Testbench normalizado en [-1, +1) con 12 bits
[~, s] = genInput(amplitude, tones, Nfft, fs);   % senal unipolar en [0, 1)
x1 = 2*s - 1;                                    % bipolar en [-1, +1)
rng(1);                                          % semilla fija
xr = 2*rand(Nfft, Nframes-1) - 1;                % ruido uniforme en [-1, +1)
X  = [x1(:), xr];                                % una trama por columna
Xq = quantize(qin, X);                           % entrada de 12 bits

SQNR_in = sqnr(X, Xq);
fprintf('SQNR de la entrada a 12 bits: %.1f dB\n', SQNR_in);

f = (-Nfft/2:Nfft/2-1)*fs/Nfft;                  % eje de frecuencias centrado
figure('Name', 'Testbench');
subplot(2,1,1); stairs(0:Nfft-1, Xq(:,1)); grid on;
xlabel('n'); ylabel('x_q[n]'); title('Trama 1 (tonos), cuantizada a [12,11]');
subplot(2,1,2); plot(f/1e6, 20*log10(fftshift(abs(fft(Xq(:,1)))) + eps)); grid on;
xlabel('f (MHz)'); ylabel('|X| (dB)'); title('Espectro de la trama 1');

% 2) Modelo flotante FlexFFT frente a fft de MATLAB
Yref  = fft(Xq);                                 % referencia (columna a columna)
Yflex = zeros(Nfft, Nframes);
for fr = 1:Nframes
    Yflex(:, fr) = FlexFFT(Nfft, Xq(:, fr));     % tambien genera W_coef.h
end
err_flex = abs(Yflex - Yref);
fprintf('Error max. |FlexFFT - fft| = %.3e\n', max(err_flex(:)));

figure('Name', 'FlexFFT vs fft');
subplot(2,1,1);
stem(f/1e6, fftshift(abs(Yref(:,1))), 'b'); hold on;
plot(f/1e6, fftshift(abs(Yflex(:,1))), 'r.'); grid on;
legend('fft', 'FlexFFT'); xlabel('f (MHz)'); ylabel('|X|');
subplot(2,1,2); stem(f/1e6, fftshift(err_flex(:,1))); grid on;
xlabel('f (MHz)'); ylabel('|error|'); title('FlexFFT - fft (precision de maquina)');

% 3) Barrido de F con twiddles casi ideales
Bw_ideal = 26;  F_ideal = 26;
Fv  = 6:20;
sqF = zeros(size(Fv));  sqF_tr = zeros(size(Fv));  ovF = zeros(size(Fv));
for ii = 1:numel(Fv)
    [Y, ovF(ii)] = fft_fx_frames(Xq, Nfft, Fv(ii), Bw_ideal, 'round');
    sqF(ii)      = sqnr(Yref, Y);
    Y            = fft_fx_frames(Xq, Nfft, Fv(ii), Bw_ideal, 'floor');
    sqF_tr(ii)   = sqnr(Yref, Y);
    fprintf('  F = %2d: SQNR %.1f dB (redondeo), %.1f dB (truncado), overflows %d\n', ...
            Fv(ii), sqF(ii), sqF_tr(ii), ovF(ii));
end

% 4) Barrido de Bw con datos casi ideales
Bwv  = 6:20;
sqBw = zeros(size(Bwv));
for ii = 1:numel(Bwv)
    Y = fft_fx_frames(Xq, Nfft, F_ideal, Bwv(ii), 'round');
    sqBw(ii) = sqnr(Yref, Y);
    fprintf('  Bw = %2d: SQNR %.1f dB\n', Bwv(ii), sqBw(ii));
end

margen = 10;                                     % dB por encima del ruido de entrada
figure('Name', 'Barridos');
subplot(1,2,1);
plot(Fv, sqF, 'o-', Fv, sqF_tr, 's--'); hold on;
yline(SQNR_in, 'k:', 'SQNR entrada'); yline(SQNR_in + margen, 'r--', 'objetivo');
grid on; xlabel('F (bits fraccionarios)'); ylabel('SQNR (dB)');
legend('redondeo', 'truncado', 'Location', 'southeast');
title(sprintf('B_w = %d', Bw_ideal));
subplot(1,2,2);
plot(Bwv, sqBw, 'o-'); hold on;
yline(SQNR_in, 'k:', 'SQNR entrada'); yline(SQNR_in + margen, 'r--', 'objetivo');
grid on; xlabel('B_w (bits twiddle)'); ylabel('SQNR (dB)');
title(sprintf('F = %d', F_ideal));

% 5) Mapa conjunto F x Bw y eleccion por coste
Fg  = 10:18;  Bwg = 10:20;
Xg  = Xq(:, 1:5);  Yg = fft(Xg);                % 5 tramas para ir mas rapido
SQ  = zeros(numel(Bwg), numel(Fg));
DSP = zeros(size(SQ));  MEM = zeros(size(SQ));
for a = 1:numel(Fg)
    for b = 1:numel(Bwg)
        Y = fft_fx_frames(Xg, Nfft, Fg(a), Bwg(b), 'round');
        SQ(b, a) = sqnr(Yg, Y);
        [DSP(b, a), MEM(b, a)] = fft_cost(Nfft, Fg(a), Bwg(b));
    end
end

figure('Name', 'Mapa SQNR');
contour(Fg, Bwg, SQ, 60:5:100, 'ShowText', 'on'); hold on;
contour(Fg, Bwg, SQ, (SQNR_in + margen)*[1 1], 'r', 'LineWidth', 2);
grid on; xlabel('F (bits fraccionarios datos)'); ylabel('B_w (bits twiddle)');
title('SQNR (dB); en rojo, el objetivo');

ok    = SQ >= SQNR_in + margen;
coste = DSP*1e6 + MEM;                          % prioridad: DSPs, luego memoria
coste(~ok) = inf;
if ~any(ok(:)), error('Ninguna configuracion cumple: amplia Fg/Bwg'); end
[~, idx] = min(coste(:));
[b, a]   = ind2sub(size(coste), idx);
Fopt = Fg(a);  Bwopt = Bwg(b);

% 6) Verificacion de la configuracion elegida
[Yfx, nov] = fft_fx_frames(Xq, Nfft, Fopt, Bwopt, 'round');
fprintf('\nConfiguracion elegida: F = %d, Bw = %d\n', Fopt, Bwopt);
fprintf('  SQNR interna = %.1f dB (entrada: %.1f dB), overflows = %d\n', ...
        sqnr(Yref, Yfx), SQNR_in, nov);
fprintf('  Error max. |Yfx - Yref| = %.3e\n', max(abs(Yfx(:) - Yref(:))));
fprintf('  Etapa | formato salida | multiplicador\n');
for m = 1:Nstage
    if m < Nstage, mul = sprintf('%2d x %2d', Fopt+m+1, Bwopt); else, mul = '   -   '; end
    fprintf('    %d   |    [%2d,%2d]     |  %s\n', m, Fopt+m+1, Fopt, mul);
end
[dsp, mem] = fft_cost(Nfft, Fopt, Bwopt);
fprintf('  DSP48 estimados: %d, memoria de retardos: %d bits\n', dsp, mem);

figure('Name', 'Resultado final');
subplot(2,1,1);
plot(f/1e6, 20*log10(fftshift(abs(Yref(:,1))) + eps), 'b', ...
     f/1e6, 20*log10(fftshift(abs(Yfx(:,1)))  + eps), 'r--'); grid on;
legend('flotante', 'punto fijo'); xlabel('f (MHz)'); ylabel('|X| (dB)');
title(sprintf('Trama 1: F = %d, B_w = %d', Fopt, Bwopt));
subplot(2,1,2); stem(f/1e6, fftshift(abs(Yfx(:,1) - Yref(:,1)))); grid on;
xlabel('f (MHz)'); ylabel('|error|'); title('Error punto fijo - flotante');

% ---------------- funciones locales ----------------
function [Y, nov] = fft_fx_frames(Xq, N, F, Bw, rmode)
% Aplica FlexFFT_fx a cada columna (trama) de Xq
Y = zeros(size(Xq));  nov = 0;
for fr = 1:size(Xq, 2)
    [Y(:, fr), o] = FlexFFT_fx(N, Xq(:, fr), F, Bw, rmode);
    nov = nov + o;
end
end

function [dsp, mem] = fft_cost(N, F, Bw)
% Coste estimado de una FFT radix-2 SDF (1 mariposa por etapa) en un FPGA
% con DSP48E1 (multiplicador con signo de 25x18)
S = log2(N);  dsp = 0;  mem = 0;
for m = 1:S
    mem = mem + 2*(N/2^m)*(F + m);              % retardo de N/2^m palabras complejas
    if m < S                                    % la ultima etapa no multiplica
        wl  = F + m + 1;                        % ancho de (a - b)
        dsp = dsp + 4*ceil(wl/25)*ceil(Bw/18);  % 4 productos reales por mult. complejo
    end
end
end
