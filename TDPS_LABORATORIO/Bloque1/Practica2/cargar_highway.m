function [X,H,W,indices] = cargar_highway(carpetaInput)
% Los archivos se llaman frame_001.png, frame_002.png, etc.

% Las imagenes del paquete ya estan en escala de grises y reducidas a
% 320 x 180 pixeles. Por eso pasoEspacial=1: no hace falta reducirlas otra vez.

    indices = 1:90; % El fotograma 87 no se creo durante el proceso de extracción de fotogramas
    pasoEspacial = 1;

    for j = 1:numel(indices)
        nombre = sprintf('frame_%03d.png',indices(j));
        ruta = fullfile(carpetaInput,nombre);

        if ~exist(ruta,'file')
            error('No se encuentra el fotograma: %s',ruta);
        end

        I = imread(ruta);

        % En este paquete los PNG son de 16 bits. Tambien admitimos uint8.
        tipoImagen = class(I);
        if ~isa(I,'uint8') && ~isa(I,'uint16')
            error('Se esperan imagenes PNG uint8 o uint16.');
        end
        I = double(I)/double(intmax(tipoImagen));

        % Si la imagen tiene tres canales, la convertimos a escala de gris.
        if ndims(I)==3 && size(I,3)==3
            I = 0.2989*I(:,:,1)+0.5870*I(:,:,2)+0.1140*I(:,:,3);
        elseif ~ismatrix(I)
            error('Formato de imagen no compatible.');
        end

        % Ya estan reducidas a 320 x 180; pasoEspacial vale 1.
        I = I(1:pasoEspacial:end,1:pasoEspacial:end);

        if j==1
            [H,W] = size(I);
            X = zeros(H*W,numel(indices));
        elseif ~isequal(size(I),[H W])
            error('Los fotogramas no tienen las mismas dimensiones.');
        end

        % Guardamos cada imagen como una columna de la matriz X.
        X(:,j) = I(:);
    end
end
