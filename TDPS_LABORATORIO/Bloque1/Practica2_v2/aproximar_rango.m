function L = aproximar_rango(U,S,V,k)
% U,S,V proceden de [U,S,V] = svd(X,'econ').
% L debe tener el mismo tamano que X y rango a lo sumo k.
% Conserva las primeras k columnas de U y V y el bloque k x k de S.
    L = U(:,1:k)*S(1:k,1:k)*V(:,1:k)';
end
