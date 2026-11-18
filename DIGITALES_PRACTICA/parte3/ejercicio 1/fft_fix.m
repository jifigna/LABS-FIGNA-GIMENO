function X = fft_fix(N, x, F, Bw)
% FFT en punto fijo con FlexBtfly: F bits fraccionarios en datos, Bw bits en W

Nstage = log2(N);

for n=0:N/2-1
    W(n+1) = exp(-1i*2*pi*n/N);
end
qw = quantizer('fixed','round','saturate',[Bw Bw-1]);
Wmax = 1 - 2^-(Bw-1);                % W=1 no entra en [Bw Bw-1]: se recorta
W  = quantize(qw,min(real(W),Wmax)) + 1i*quantize(qw,min(imag(W),Wmax));

dataout = x;
for m=1:Nstage
    q = quantizer('fixed','round','saturate',[F+m+1 F]);   % +1 bit entero por etapa
    if m==Nstage
        W = ones(size(W));
    end
    for n=1:2^(m-1)
        idx = (n-1)*N/2^(m-1)+1 : n*N/2^(m-1);
        y = FlexBtfly(N/2^(m-1), dataout(idx), W(1:2^(m-1):N/2));
        dataout(idx) = quantize(q,real(y)) + 1i*quantize(q,imag(y));
    end
end

X = dataout;
for m=1:N
    X(bin2dec(fliplr(dec2bin(m-1,Nstage)))+1) = dataout(m);
end
