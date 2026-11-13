function specgram(signal, ~, fs)
% specgram  Sustituto de la antigua funcion specgram (ya no existe en MATLAB).
%   genInput.m de Parte1 la llama al final; con este archivo en la carpeta
%   del ejercicio funciona sin modificar el original.
nwin = min(128, numel(signal));
spectrogram(signal, nwin, round(0.75*nwin), max(256, nwin), fs, 'yaxis');
end
