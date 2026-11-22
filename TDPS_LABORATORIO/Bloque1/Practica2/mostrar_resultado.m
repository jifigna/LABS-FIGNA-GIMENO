function mostrar_resultado(X,L,H,W,j,numeroFrame,k)
% j es el indice de columna; numeroFrame es el numero del fotograma original.

    I = reshape(X(:,j),H,W);
    B = reshape(L(:,j),H,W);
    R = abs(I-B);

    subplot(1,3,1);
    imagesc(I,[0 1]); axis image off; colorbar;
    title(sprintf('Fotograma %d',numeroFrame));

    subplot(1,3,2);
    imagesc(B,[0 1]); axis image off; colorbar;
    title(sprintf('Fondo estimado, k=%d',k));

    subplot(1,3,3);
    imagesc(R,[0 0.5]); axis image off; colorbar;
    title('Residuo absoluto');

    colormap(gray(256));
end
