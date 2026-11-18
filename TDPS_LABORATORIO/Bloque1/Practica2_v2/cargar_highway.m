function [X,H,W,indices] = cargar_highway(carpetaInput)
% Lee in000001.jpg, etc. No requiere convertir la secuencia a video.
% Propuesta de muestreo: 200 fotogramas, del 1 al 399, de dos en dos.
    indices = 1:2:399;
    pasoEspacial = 2;
    for j = 1:numel(indices)
        nombre = sprintf('in%06d.jpg',indices(j));
        ruta = fullfile(carpetaInput,nombre);
        if ~exist(ruta,'file')
            error('No se encuentra el fotograma: %s',ruta);
        end
        I = imread(ruta);
        if ~isa(I,'uint8')
            error('Se esperan imagenes JPEG uint8.');
        end
        I = double(I)/255;
        if ndims(I)==3 && size(I,3)==3
            I = 0.2989*I(:,:,1)+0.5870*I(:,:,2)+0.1140*I(:,:,3);
        elseif ~ismatrix(I)
            error('Formato de imagen no compatible.');
        end
        I = I(1:pasoEspacial:end,1:pasoEspacial:end);
        if j==1
            [H,W] = size(I);
            X = zeros(H*W,numel(indices));
        elseif ~isequal(size(I),[H W])
            error('Los fotogramas no tienen las mismas dimensiones.');
        end
        X(:,j) = I(:);
    end
end
