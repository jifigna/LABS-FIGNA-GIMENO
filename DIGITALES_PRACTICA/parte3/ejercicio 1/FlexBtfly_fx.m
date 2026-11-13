function dataout = FlexBtfly_fx(N, datain, W, qd)
% FlexBtfly_fx  Mariposa DIF en punto fijo (equivalente a FlexBtfly de Parte1).
%   Mitad superior: a + b          -> sumador
%   Mitad inferior: (a - b) * W    -> restador + multiplicador complejo
%   qd: quantizer con el formato de salida de la etapa
a = datain(1:N/2);
b = datain(N/2+1:N);
s = qc(qd, a + b);              % sumador: cabe gracias al bit de crecimiento
d = qc(qd, a - b);              % restador
p = qc(qd, d .* W);             % producto exacto, redondeado a F bits fraccionarios
dataout = [s, p];
end
