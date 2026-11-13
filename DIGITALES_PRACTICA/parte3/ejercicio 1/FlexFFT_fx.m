function [dataoutf, nOvf] = FlexFFT_fx(N, datain, F, Bw, rmode)
% FlexFFT_fx  Modelo en punto fijo de FlexFFT (Parte1/sources/matlab).
%   N      : puntos (512)
%   datain : entrada ya cuantizada a [12,11]
%   F      : bits fraccionarios del camino de datos
%   Bw     : bits de los twiddles, formato [Bw, Bw-1]
%   rmode  : 'round' (redondeo) o 'floor' (truncado). Por defecto 'round'
if nargin < 5, rmode = 'round'; end

Nstage = log2(N);

% Twiddles: mismos valores que FlexFFT / W_coef.h, ahora cuantizados (ROM)
n  = 0:N/2-1;
W  = exp(-1i*2*pi*n/N);
qw = quantizer('fixed', rmode, 'saturate', [Bw Bw-1]);
W  = qc(qw, W);

dataout = datain(:).';          % trabajo con vector fila
nOvf    = 0;

for m = 1:Nstage
    % formato de salida de la etapa m: crece 1 bit entero por etapa
    qd = quantizer('fixed', rmode, 'saturate', [F+m+1, F]);
    if m == Nstage
        W = ones(size(W));      % ultima etapa: sin multiplicador
    end
    L  = N/2^(m-1);             % tamano de cada bloque
    Wm = W(1:2^(m-1):N/2);      % twiddles usados en esta etapa
    for k = 1:2^(m-1)
        idx = (k-1)*L+1 : k*L;
        dataout(idx) = FlexBtfly_fx(L, dataout(idx), Wm, qd);
    end
    nOvf = nOvf + noverflows(qd);
end

% Reordenacion bit-reverse (igual que FlexFFT, vectorizada)
rev = bin2dec(fliplr(dec2bin(0:N-1, Nstage))) + 1;
dataoutf = zeros(size(dataout));
dataoutf(rev) = dataout;
dataoutf = reshape(dataoutf, size(datain));   % misma orientacion que la entrada
end
