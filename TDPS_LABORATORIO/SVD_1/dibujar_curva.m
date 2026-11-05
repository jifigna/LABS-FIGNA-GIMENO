function h = dibujar_curva(theta, limites, estilo)
% Dibuja F(x,y)=0 sin despejar y ni clasificar la conica.
% limites = [xmin xmax ymin ymax]. Se usa sobre el eje actual.
x = linspace(limites(1), limites(2), 500);
y = linspace(limites(3), limites(4), 500);
[X,Y] = meshgrid(x,y);
F = theta(1)*X.^2 + theta(2)*X.*Y + theta(3)*Y.^2 ...
+ theta(4)*X + theta(5)*Y + theta(6);
[~,h] = contour(X,Y,F,[0 0],estilo,"LineWidth",2);
end