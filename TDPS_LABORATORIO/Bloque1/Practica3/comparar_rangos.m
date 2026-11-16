% Comparar rangos k=10,20,50 en fotografias reales.
% Completar aproximar_rango.m antes de ejecutar.
clear; close all; clc;
[nombres,carpeta] = uigetfile({'*.jpg;*.jpeg;*.png','Fotografias PNG/JPEG'}, ...
    'Selecciona al menos dos imagenes','MultiSelect','on');
if isequal(nombres,0), return; end
if ischar(nombres), nombres={nombres}; end
if numel(nombres)<1, error('Selecciona al menos una fotografia.'); end
salida='resultados_rangos';
if ~exist(salida,'dir'), mkdir(salida); end
ks=[10 20 50];
for j=1:numel(nombres)
    A=leer_imagen_gris(fullfile(carpeta,nombres{j}));
    [U,S,V]=svd(A,'econ'); % Una sola SVD por imagen.
    s=diag(S); [m,n]=size(A);
    errores=zeros(3,1); energias=zeros(3,1); factores=zeros(3,1);
    aproximaciones=cell(3,1);
    fig=figure('Color','w','Position',[80 80 1100 650]);
    subplot(2,3,1); imagesc(A,[0 1]); axis image off;
    title('Original en gris','Interpreter','none');
    for i=1:3
        k=ks(i);
        Ak=aproximar_rango(U,S,V,k);
        aproximaciones{i}=Ak;
        % Medir ANTES de recortar intensidades para visualizacion.
        errores(i)=norm(A-Ak,'fro')/norm(A,'fro');
        energias(i)=sum(s(1:k).^2)/sum(s.^2);
        factores(i)=m*n/(k*(m+n+1));
        subplot(2,3,i+1); imagesc(Ak,[0 1]); axis image off;
        title(sprintf('k=%d; error=%.3f',k,errores(i)));
        % PNG solo para visualizar; la matriz sin recortar va al .mat.
        imwrite(min(max(Ak,0),1), ...
            fullfile(salida,sprintf('imagen_%02d_k%d.png',j,k)));
    end
    subplot(2,3,5); semilogy(1:numel(s),max(s,eps),'o-');
    xlabel('Indice'); ylabel('Valor singular'); grid on;
    subplot(2,3,6); plot(ks,errores,'o-');
    xlabel('k'); ylabel('Error relativo'); grid on;
    colormap(gray(256));
    print(fig,fullfile(salida,sprintf('imagen_%02d_comparacion.png',j)), ...
        '-dpng','-r150');
    resultados=table(ks',errores,energias,factores, ...
        'VariableNames',{'k','ErrorRelativo','EnergiaConservada', ...
        'FactorAhorroEscalares'});
    writetable(resultados, ...
        fullfile(salida,sprintf('imagen_%02d_resultados.csv',j)));
    nombreOriginal=nombres{j};
    save(fullfile(salida,sprintf('imagen_%02d_datos.mat',j)), ...
        'A','aproximaciones','s','resultados','nombreOriginal');
    imwrite(A,fullfile(salida,sprintf('imagen_%02d_original_gris.png',j)));
    fprintf('\n%s (%d x %d)\n',nombres{j},m,n); disp(resultados);
end
