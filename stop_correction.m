function MASKED = stop_correction(MASKED,image_filt,image_grad,z,POS)
loadbar = waitbar(0,'correcting...');
for I=1:numel(POS)
    i = POS(I);
    im = image_filt(:,:,i);
    im_grad = image_grad(:,:,i).*z;
    %Obtencion de objetos más brillantes
    m = max(im_grad(:));
    m1 = im_grad>0.15*m;
    m2 = im_grad>0.7*m;
    mask = imreconstruct(m2,m1); 
    %Filtro de tamaños y orientaciones para eliminar objetos pequeños
    stats = regionprops(mask,'Area','PixelIdxList'); 
    area = [stats.Area]; pixel = {stats.PixelIdxList};
    if numel(area)>1
        mask = 0*mask;
        position = find(area>0.5*mean(area)); % tamaño mayor que la mitad de la media
        for j=1:numel(position)
            mask(pixel{position(j)}) = 1;
        end
        mask = logical(mask);
        % encontrar el pixel más a la izquierda
        stats = regionprops(mask,'PixelList');
        pixel = {stats.PixelList}; 
        if numel(pixel)>1
            COLUMNS = zeros(numel(pixel),1);
            for j=1:numel(pixel);
                column = pixel{j}(:,1); %columnas de los pixeles del objeto
                COLUMNS(j) = min(column); % columna más a la izquierda del objeto
            end
            pos = find(COLUMNS==min(COLUMNS)); % cogemos el objeto más a la izquierda
            mask = 0*mask;
            pixel = pixel{pos};
            for j=1:size(pixel,1)
                mask(pixel(j,2),pixel(j,1))=1;
            end
        end
    end
    %determinar la orientación del objeto para la direccion de crecimiento
    mask = logical(mask);
    stats = regionprops(mask,'Orientation');
    angle = stats.Orientation;

    % eliminar posibles puntos no pertenecientes al cartilago 
    im_mask = im.*mask;
    position = find(mask==1);
    m = mean(im(position));
    mask = im_mask>m;

    % Generamos el strel para la dilatación basandonos en la orientación
    se = [0 1 1;0 1 1;0 1 1]; 
    if angle>0
        se = imrotate(se,-90+angle);
    else
        se = imrotate(se,90+angle);
    end

    % Primer ciclo del crecimiento de regiones
    m = mean(im(mask==1));
    sd = std(im(mask==1));
    mask_grow = imdilate(mask,se);
    mask_diff = logical(mask_grow - mask);
    M = []; M(1) = mean(im(mask_diff==1));
    S = []; S(1) = std(im(mask_diff==1));
    mask_diff(mask_diff.*im<m-sd)=0;
    mask_grow = mask+mask_diff;

    p=1; %contandor del número de iteraciones del crecimiento
    height = []; %aquí va la altura del punto inferior del objeto de crecimiento
    for j=size(mask,1):-1:1
        a = sum(mask_diff(j,:));
        if a>0
           a=j;
            break
        end
    end
    height(p) = a;    
    MASK = {}; %Aquí se almacenan las mascaras según la iteración
    MASK{1} = mask_grow;

    while bwarea(mask_grow)>bwarea(mask)
        p=p+1;
        mask = mask_grow;
        mask_grow = imdilate(mask,se);
        mask_diff = logical(mask_grow-mask);
        m = mean(im(mask==1));
        sd = std(im(mask==1));
        stats = regionprops(mask_diff,'PixelList');
        pixel = {stats.PixelList};
        mask_diff(mask_diff.*im<m-2*sd)=0;
        mask_grow = mask+mask_diff;
        for j=size(mask,1):-1:1
            a = sum(mask_diff(j,:));
            if a>0
                a=j;
                break
            end
        end
        height(p) = a;    
        MASK{p} = mask_grow;
        if   p>3 && height(p)-height(p-1)>=0 &&  height(p-1)-height(p-2)<=0
            mask = MASK{p-1};
            p = p-1;
            break
        end
    
        if  height(p)>height(1)+3
            break
        end
        if p>10 %pixel = 0.293 mm 0.293*10=2.293 mm de limite aproximado
            break;
        end
    end
    %limites para el crecimiento
    %limite lateral
    a = find(mask(height(p),:)==1,1,'last');
    if isempty(a)==1
        a = find(mask(height(p-1),:)==1,1,'last');
    end
    %limite superior
    for b=1:size(mask,1)
        if sum(mask(b,:))>0
            break
        end
    end
        
    black_limit = mask*0+1;  black_limit(height(p)+1:size(mask,1),:)=0; %limite inferior
    black_limit(:,a:size(mask,2))=0; %limite lateral
    black_limit(b+1,:)=0; %limite superior
    
    % nuevo crecimiento para completar zona superior
    mask_grow = imdilate(mask,[0 0 0;0 1 1;0 1 1]);
    mask_grow = logical(mask_grow.*black_limit);
    m = mean(im(mask==1)); sd = std(im(mask==1));
    mask_diff = logical(mask_grow-mask);
    mask_diff(mask_diff.*im<m-2*sd)=0 ; mask_grow = mask+mask_diff;
    p=0;
    while bwarea(mask_grow)>bwarea(mask)
        p=p+1;
        if p>15
            break
        end
        mask = mask_grow;
        mask_grow = imdilate(mask,[0 0 0;0 1 1;0 1 1]);
        mask_grow = logical(mask_grow).*black_limit;
        m = mean(im(mask==1)); sd = std(im(mask==1));
        mask_diff = logical(mask_grow-mask);
        mask_diff(mask_diff.*im<m-sd)=0 ; mask_grow = mask+mask_diff;
    end
    %% modificaciones finales, eliminar puntos de bajo valor y objetos residuales
    stats = regionprops(logical(mask),'Area','PixelIdxList');
    area = [stats.Area]; pixel = {stats.PixelIdxList};
    if numel(area)>1
        pos = find(area==max(area));
        mask = 0*mask;
        mask(pixel{pos}) = 1;
    end
    mask(im.*mask<80) = 0; % umbral de 80 es el mínimo aproximado
    stats = regionprops(logical(mask),'Area','PixelIdxList');
    area = [stats.Area]; pixel = {stats.PixelIdxList};
    if numel(area)>1
        mask = 0*mask;
        pos = find(area>0.1*max(area));
        for j=1:numel(pos)
            mask(pixel{pos(j)})=1;
        end
    end
    mask = imfill(logical(mask),'holes'); % rellenamos posibles huecos
    MASKED(:,:,i)=logical(mask);
    waitbar(I/numel(POS))
end
close(loadbar)