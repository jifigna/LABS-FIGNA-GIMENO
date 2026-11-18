% EJERCICIO 2: fondo y movimiento en la secuencia highway.
clear; close all; clc;

% carpetaInput = uigetdir(pwd,'Selecciona la carpeta input de KITT');
carpetaInput = uigetdir(pwd,'Selecciona la carpeta input de highway');
if isequal(carpetaInput,0), return; end
[X,H,W,indices] = cargar_highway(carpetaInput);
carpetaSalida = 'resultados_highway';
if ~exist(carpetaSalida,'dir'), mkdir(carpetaSalida); end

% Una sola SVD de la matriz de FOTOGRAMAS, no de cada imagen por separado.
[U,S,V] = svd(X,'econ');
valores = diag(S);
rangos = [1 2 5];
% columnasMostrar = [1 90];
columnasMostrar = [50 150]; % Corresponden a in000099 e in000299.
errores = zeros(numel(rangos),1);
energias = zeros(numel(rangos),1);

for i = 1:numel(rangos)
    k = rangos(i);
    L = aproximar_rango(U,S,V,k);
    errores(i) = norm(X-L,'fro')/norm(X,'fro');
    energias(i) = sum(valores(1:k).^2)/sum(valores.^2);
    for j = columnasMostrar
        fig = figure('Color','w','Position',[100 100 1100 350]);
        mostrar_resultado(X,L,H,W,j,indices(j),k);
        % nombre = sprintf('k %d_frame %06d.png',k,indices(j));
        nombre = sprintf('k%d_frame%06d.png',k,indices(j));
        print(fig,fullfile(carpetaSalida,nombre),'-dpng','-r150');
        close(fig);
    end
end

fig = figure('Color','w');
semilogy(1:numel(valores),max(valores,eps),'o-'); grid on;
xlabel('Indice'); ylabel('Valor singular');
title('Espectro singular de la matriz de fotogramas');
print(fig,fullfile(carpetaSalida,'espectro.png'),'-dpng','-r150');
close(fig);

resultados = table(rangos(:),errores,energias, ...
    'VariableNames',{'Rango','ErrorRelativoReconstruccion','EnergiaConservada'});
disp(resultados);
writetable(resultados,fullfile(carpetaSalida,'resultados.csv'));

% Guardar solo factores necesarios para reproducir los tres rangos.
U5=U(:,1:5); S5=S(1:5,1:5); V5=V(:,1:5);
save(fullfile(carpetaSalida,'resultados.mat'), ...
    'U5','S5','V5','valores','H','W','indices','resultados','carpetaInput');
