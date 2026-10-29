clear; close all; clc;

N = 120;
sigma = 0.03;
[P, Pref] = generar_puntos(N, sigma);

% Se conservan exactamente los mismos puntos y el mismo ruido.
% Los outliers se AÑADEN: no se sustituyen puntos originales.
Nout = 15;
O = [-3 + 6*rand(Nout, 1), -2.5 + 5*rand(Nout, 1)]; % Letra 'O' para Outliers
Pcont = [P; O];
limites = [-3.2 3.2 -2.7 2.7];

[theta0, s0] = ajustar_curva_svd(P);
[theta1, s1] = ajustar_curva_svd(Pcont);

fig = figure('Color', 'w', 'Position', [100 100 1100 450]);

for caso = 1:2
    subplot(1,2, caso); hold on;
    hp = plot(P(:,1), P(:,2), '.', 'Color', [0.2 0.4 0.8]);
    hr = plot(Pref(:,1), Pref(:,2), 'k--', 'LineWidth', 1.2);
    
    if caso == 1
        hc = dibujar_curva(theta0, limites, 'r-');
        legend([hp hr hc], {'Datos', 'Referencia', 'Ajuste SVD'}, 'Location', 'best');
        title('Sin outliers');
    else
        ho = plot(O(:,1), O(:,2), 'mx', 'LineWidth', 1.5);
        hc = dibujar_curva(theta1, limites, 'r-');
        legend([hp hr ho hc], {'Datos', 'Referencia', 'Outliers', 'Ajuste SVD'}, 'Location', 'best');
        title('Con 15 outliers');
    end
    
    axis equal; axis(limites); grid on;
    xlabel('x'); ylabel('y');
end
print(fig, fullfile(carpeta, 'comparacion.png'), '-dpng', '-r150');

% Evaluación en los MISMOS puntos de referencia, no en los outliers.
x = Pref(:,1); y = Pref(:,2);
Dref = [x.^2, x.*y, y.^2, x, y, ones(size(x))];
E0 = sqrt(mean((Dref*theta0).^2));
E1 = sqrt(mean((Dref*theta1).^2));

fprintf('RMS algebraico sobre referencia (theta de norma 1):\n');
fprintf(' Sin outliers: %.6g\n', E0);
fprintf(' Con outliers: %.6g\n', E1);

resultados = table({'Sin outliers'; 'Con outliers'}, ...
    [N; N+Nout], [E0; E1], ...
    'VariableNames', {'Caso', 'NumeroPuntos', 'RMSAlgebraicoReferencia'});
writetable(resultados, fullfile(carpeta, 'resultados.csv'));

save(fullfile(carpeta, 'resultados.mat'), ...
    'P', 'Pref', 'O', 'theta0', 'theta1', 's0', 's1', 'resultados');