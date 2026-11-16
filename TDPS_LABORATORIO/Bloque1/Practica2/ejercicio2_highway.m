% EJERCICIO 2: fondo y movimiento en la secuencia de KITT.
% Se conserva la estructura y los nombres de archivo de la practica original.
% Compatible con MATLAB R2024b.

clear; close all; clc;

% Seleccionamos la carpeta input, igual que en el enunciado original.
carpetaInput = uigetdir(pwd,'Selecciona la carpeta input de KITT');
if isequal(carpetaInput,0), return; end

% Leemos los fotogramas y construimos la matriz X.
[X,H,W,indices] = cargar_highway(carpetaInput);

% Conservamos el nombre de la carpeta de salida del enunciado.
carpetaSalida = 'resultados_highway';
if ~exist(carpetaSalida,'dir'), mkdir(carpetaSalida); end

% Una sola SVD de la matriz de FOTOGRAMAS, no de cada imagen por separado.
[U,S,V] = svd(X,'econ');
valores = diag(S);
rangos = [1 2 5];

% Se muestran el primer y ultimo fotograma disponible de KITT.
% Son las columnas 1 y 90, que corresponden a frame_001 y frame_091.
columnasMostrar = [1 90];

errores = zeros(numel(rangos),1);
energias = zeros(numel(rangos),1);

for i = 1:numel(rangos)
    k = rangos(i);
    L = aproximar_rango(U,S,V,k);

    % Error relativo de reconstruccion de toda la secuencia.
    errores(i) = norm(X-L,'fro')/norm(X,'fro');

    % Energia conservada por los primeros k valores singulares.
    energias(i) = sum(valores(1:k).^2)/sum(valores.^2);

    for j = columnasMostrar
        fig = figure('Color','w','Position',[100 100 1100 350]);
        mostrar_resultado(X,L,H,W,j,indices(j),k);
        nombre = sprintf('k %d_frame %06d.png',k,indices(j));
        print(fig,fullfile(carpetaSalida,nombre),'-dpng','-r150');
        close(fig);
    end
end

% Espectro singular de la matriz de fotogramas.
fig = figure('Color','w');
semilogy(1:numel(valores),max(valores,eps),'o-'); grid on;
xlabel('Indice'); ylabel('Valor singular');
title('Espectro singular de la matriz de fotogramas');
print(fig,fullfile(carpetaSalida,'espectro.png'),'-dpng','-r150');
close(fig);

% Tabla con las mismas metricas que solicita el enunciado.
resultados = table(rangos(:),errores,energias, ...
    'VariableNames',{'Rango','ErrorRelativoReconstruccion','EnergiaConservada'});
disp(resultados);
writetable(resultados,fullfile(carpetaSalida,'resultados.csv'));

% Guardamos solo los cinco primeros modos, suficientes para k=1,2,5.
U5=U(:,1:5); S5=S(1:5,1:5); V5=V(:,1:5);
save(fullfile(carpetaSalida,'resultados.mat'), ...
    'U5','S5','V5','valores','H','W','indices','resultados','carpetaInput');

