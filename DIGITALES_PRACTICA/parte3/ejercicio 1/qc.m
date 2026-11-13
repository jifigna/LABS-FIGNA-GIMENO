function y = qc(q, x)
% qc  Cuantiza un numero complejo con el quantizer q
%     (parte real e imaginaria por separado, como en hardware)
y = quantize(q, real(x)) + 1i*quantize(q, imag(x));
end
