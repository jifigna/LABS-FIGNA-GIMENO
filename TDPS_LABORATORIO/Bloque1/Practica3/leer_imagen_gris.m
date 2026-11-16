function A = leer_imagen_gris(ruta)
% PNG/JPEG real, gris o RGB, de 8 o 16 bits.
    [I,map] = imread(ruta);
    if ~isempty(map)
        error('Usa una imagen RGB o gris, no una imagen indexada.');
    end
    if isinteger(I)
        A = double(I)/double(intmax(class(I)));
    elseif islogical(I)
        A = double(I);
    else
        A = double(I);
        if any(~isfinite(A(:))) || any(A(:)<0) || any(A(:)>1)
            error('Las imagenes de coma flotante deben estar en [0,1].');
        end
    end
    if ndims(A)==3 && size(A,3)==3
        A = 0.2989*A(:,:,1)+0.5870*A(:,:,2)+0.1140*A(:,:,3);
    elseif ~ismatrix(A)
        error('Formato no compatible: usa gris o RGB.');
    end
    % Submuestreo sencillo para limitar el coste de la SVD.
    paso = max(1,ceil(max(size(A))/512));
    A = A(1:paso:end,1:paso:end);
    if min(size(A))<5 || norm(A,'fro')==0
        error('Usa una imagen no negra con al menos 5 filas y columnas.');
    end
end
