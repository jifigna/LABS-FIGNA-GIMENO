function [theta, valores] = ajustar_curva_svd(P)
% COMPLETAR POR EL ALUMNADO.
% Entrada: P, matriz N x 2, con N >= 6.
% Salidas: theta, vector 6 x 1; valores, valores singulares de D.
    x = P(:,1);
    y = P(:,2);

    % PASO 1. Construir D
    % Usar .^ y .* para operaciones elemento a elemento.
    % Cada fila contiene [x_i^2, x_i*y_i, y_i^2, x_i, y_i, 1].
    D = [x.^2, x.*y, y.^2, x, y, ones(size(x))];

    % PASO 2. Calcular la SVD de D.
    % MATLAB devuelve los valores singulares en orden descendente.
    [U,S,V] = svd(D);

    % PASO 3. Elegir el vector singular derecho adecuado.
    % La ultima columna de V corresponde al menor valor singular.
    theta = V(:,end);

    % PASO 4. Extraer la diagonal de S.
    % diag(S) contiene los valores singulares de D.
    valores = diag(S);
end
