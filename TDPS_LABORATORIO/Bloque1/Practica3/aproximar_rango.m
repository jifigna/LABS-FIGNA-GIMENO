function Ak = aproximar_rango(U,S,V,k)
% COMPLETAR: usar las primeras k columnas de U y V
% y el bloque k x k superior izquierdo de S.
    Ak = U(:,1:k)*S(1:k,1:k)*V(:,1:k)';
end
