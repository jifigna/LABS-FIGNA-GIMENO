function [dataoutf]= FlexFFT (N, datain)

Nstage= log2(N);

for n=0:N/2-1
    W(n+1)= exp(1)^(-n*i*2*pi/N);
end;



dataout= datain;

for m=1:Nstage
    if m==Nstage
        W= ones(size(W));
    end;
    %waux=W(1:(2^(m-1)):N/2);
    for n=1:(2^(m-1))
        dataout((n-1)*N/(2^(m-1))+1:(n)*N/(2^(m-1)))= FlexBtfly (N/(2^(m-1)), dataout((n-1)*N/(2^(m-1))+1:(n)*N/(2^(m-1))), ...
            W(1:(2^(m-1)):N/2));
    end;
end;

dataoutf= dataout;
for m=1:length(dataout)
    dataoutf(bin2dec(fliplr(dec2bin(m-1,Nstage)))+1)= dataout(m);
end;

