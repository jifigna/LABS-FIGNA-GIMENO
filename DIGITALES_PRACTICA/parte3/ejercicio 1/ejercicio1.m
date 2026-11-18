clear all; close all; clc;

Nfft   = 512;
fs     = 62.5e6;
Nstage = log2(Nfft);
Bin    = 12;

tones     = [2e6 5e6 9e6 12e6];
amplitude = 0.5;
[t, finput] = genInput(amplitude, tones, Nfft, fs);

%% Entrada en [-1,1] con 12 bits
x1  = min(2*finput - 1, 1 - 2^-(Bin-1));     % maximo representable en [12,11]
q12 = quantizer('fixed','round','saturate',[Bin Bin-1]);
xq  = quantize(q12, x1);

figure; plot(x1); hold on; plot(xq,'r--');
title('Entrada flotante vs 12 bits');


% for llamando a la fft cuantificada , agarramos lo coef 
%% FlexFFT vs fft
f      = (-Nfft/2:Nfft/2-1)*fs/Nfft;
Xideal = fft(x1);                  % FFT ideal: entrada sin cuantizar
Xfft   = fft(xq);
Xflex  = FlexFFT(Nfft, xq);
fprintf('Error max FlexFFT vs fft: %g\n', max(abs(Xfft-Xflex)));

figure;
subplot(2,1,1); stem(f, fftshift(abs(Xfft)));  title('fft');
subplot(2,1,2); stem(f, fftshift(abs(Xflex))); title('FlexFFT');

%% Error de referencia: el que ya trae la entrada de 12 bits
err_rms = @(X) sqrt(mean(abs(Xideal - X).^2));
piso    = err_rms(Xfft);
fprintf('Error por cuantizar la entrada a 12 bits: %g\n', piso);

%% Barrido de bits de datos (W casi ideales)
Fv = 4:20;
for k = 1:length(Fv)
    err_F(k) = err_rms(fft_fix(Nfft, xq, Fv(k), 24));
end

%% Barrido de bits de W (datos casi ideales)
Bwv = 4:20;
for k = 1:length(Bwv)
    err_W(k) = err_rms(fft_fix(Nfft, xq, 24, Bwv(k)));
end

figure;
subplot(1,2,1); semilogy(Fv, err_F, 'o-', Fv, piso*ones(size(Fv)), 'r--'); grid on;
xlabel('F (bits fraccionarios datos)'); ylabel('Error RMS'); legend('FFT punto fijo', 'Piso entrada 12 bits');
subplot(1,2,2); semilogy(Bwv, err_W, 'o-', Bwv, piso*ones(size(Bwv)), 'r--'); grid on;
xlabel('Bw (bits W)'); ylabel('Error RMS');

%% Configuracion elegida: primer valor a menos de un 10% del piso
F  = Fv(find(err_F <= 1.1*piso, 1));
Bw = Bwv(find(err_W <= 1.1*piso, 1));

Xfix = fft_fix(Nfft, xq, F, Bw);

fprintf('F = %d, Bw = %d\n', F, Bw);
fprintf('Salida: %d bits [%d enteros + %d fraccionarios + signo]\n', F+Nstage+1, Nstage, F);
fprintf('Multiplicadores: %d x %d bits (etapa 8, la mas ancha)\n', F+Nstage, Bw);
fprintf('Error RMS = %g (piso %g)\n', err_rms(Xfix), piso);

figure;
subplot(2,1,1); stem(f, fftshift(abs(Xfix)));
title(sprintf('FFT punto fijo, F = %d, Bw = %d', F, Bw));
subplot(2,1,2); stem(f, fftshift(abs(Xideal - Xfix)));
title('Error punto fijo - ideal');
