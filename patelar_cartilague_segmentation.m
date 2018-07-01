function [MASKED,image_filt] = patelar_cartilague_segmentation(Image_set,slice1,slice2)

Image_set = double(Image_set);
image = Image_set*0;
image_log = image;
image_grad = image;
image_glog = image;
L = size(Image_set,3);
loadbar = waitbar(0,'filtering...');
for i=slice1:slice2
    m = max(max(Image_set(:,:,i)));
    ima = (medfilt2(Image_set(:,:,i),[10 10]).*Image_set(:,:,i));
    ima = ima/max(ima(:));
    ima = round(ima*m);
    [image_gradx, image_grady] = imgradientxy(ima);
    image(:,:,i) = ima;
    image_grad(:,:,i) = image_gradx;
    imalog = log10(ima); imalog(imalog==-Inf) = 0;
    imalog = round(imalog/max(imalog(:))*m);
    image_log(:,:,i) = imalog;
    [image_gradx, image_grady] = imgradientxy(imalog);
    image_glog(:,:,i) = image_gradx;
    waitbar((i-slice1+1)/(slice2-slice1))
end
close(loadbar)
image_filt = image;
image_grad(image_grad<0) = 0;
image_glog(image_glog<0) = 0;
%% Logarithmic gradient maximum 
image_gradmax = max(image_grad,[],3); 
image_glogmax = max(image_glog,[],3);
%% Semiautomatic ROI
% imshow(image_glogmax.^2,[])
% z = roipoly;
%% automatic ROI
s = size(image_gradmax);
image_gradmax = image_gradmax.^2;
[gradmax_grad,y] = imgradientxy(image_gradmax);
gradmax_grad(gradmax_grad<0) = 0;
gradmax_grad(:,round(s(2)/2):end) = 0;
mg = max(gradmax_grad(:));
m1 = gradmax_grad>0.1*mg;
m2 = gradmax_grad>0.9*mg;
grad_mask = imreconstruct(m2,m1);
se_updown = strel('line',20,90);
se_leftright = strel('line',40,0);
grad_mask = imdilate(grad_mask,se_updown);
grad_mask = imdilate(grad_mask,se_leftright);
z = grad_mask;
% prop = regionprops(z,'BoundingBox');
% bound = prop.BoundingBox; bound = ceil(bound);
% z(bound(2):bound(2)+bound(4),bound(1):bound(1)+bound(3)) = 1;
% figure
% imshow(z);

%% segmentacion
MASKED = image*0; % aquí se almacenan las máscaras del cartilago
ECCENTRICITY = zeros(L,1);
AREA = ECCENTRICITY;
CORRECTION_m = MASKED;
loadbar = waitbar(0,'segmenting...');
for i=slice1:slice2
    %% deteccion del primer corte
    im = image(:,:,i);
    im_grad = image_grad(:,:,i).*z;
    
    %Obtencion de objetos más brillantes
    m = max(im_grad(:));
    m1 = im_grad>0.15*m;
    m2 = im_grad>0.7*m;
    mask = imreconstruct(m2,m1); 
    
    %Filtro de tamaños y orientaciones para eliminar objetos pequeños
    stats = regionprops(mask,'Area','PixelIdxList'); 
    area = [stats.Area];
    pixel = {stats.PixelIdxList};
    if numel(area)>1
        mask = 0*mask;
        position = find(area>0.5*mean(area));
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
                column = pixel{j}(:,1);
                COLUMNS(j) = min(column);
            end
            pos = find(COLUMNS==min(COLUMNS));
            mask = 0*mask;
            pixel = pixel{pos};
            for j=1:size(pixel,1)
                mask(pixel(j,2),pixel(j,1))=1;
            end
        end
    end
    
    %eliminar puntos de bajo contraste
    m = mean(im(mask==1));
    sd = std(im(mask==1));
    mask(im.*mask<m-0.5*sd)=0; %puntos de inicio
    
    %eliminamos posibles puntos pequeños 
    stats = regionprops(mask,'Area','PixelIdxList'); 
    area = [stats.Area];
    pixel = {stats.PixelIdxList};
    if numel(area)>1
       mask = 0*mask;
       position = find(area>0.3*max(area));
       for j=1:numel(position)
            mask(pixel{position(j)})=1;
       end
       mask = logical(mask);
    end
    CORRECTION_m(:,:,i) = mask;
    se = [0 1 1;0 1 1;0 1 1]; %strel de crecimiento
    %obtener angulo del strel de crecimiento
    stats = regionprops(mask,'Orientation');
    angle = stats.Orientation;
    if angle>0
        se = imrotate(se,-90+angle);
    else
        se = imrotate(se,90+angle);
    end
    
    %% comienzo de region growing
    m = mean(im(mask==1));
    sd = std(im(mask==1));
    mask_grow = imdilate(mask,se);
    mask_diff = mask_grow - mask;
    mask_diff(mask_diff.*im<m-sd)=0; 
    stats = regionprops(logical(mask_diff),'Area','PixelIdxList'); 
    area = [stats.Area];
    pixel = {stats.PixelIdxList};
    if numel(area)>1
       mask_diff = 0*mask;
       position = find(area==max(area),1,'first');
       mask_diff(pixel{position})=1;
       mask_diff = logical(mask_diff);
    end
    height_sup = []; height_inf = []; %aquí iran las coordenadas de los puntos
    stats = regionprops(mask_diff,'Extrema');
    extrema = [stats.Extrema];
    height_sup(1,:) = floor(extrema(2,:));
    height_sup(1,2) = height_sup(1,2)+1;
    height_inf(1,:) = floor(extrema(5,:));    
    MASK = {};
    MASK{1} = mask_grow;
    min_object = {};
    min_object{1} = 0*mask;
    p=1;
    h=1;
    %% bucle de region growing con tracking de puntos 
    while bwarea(mask_grow)>bwarea(mask)
        p=p+1;
        mask = mask_grow;
        mask_grow = imdilate(mask,se);
        mask_diff = logical(mask_grow-mask);
        m = mean(im(mask==1));
        sd = std(im(mask==1));
        mask_diff(mask_diff.*im<m-sd)=0;  %límite de crecimiento
        mask_diff(height_sup(1,2):-1:1,:)=0; %límite de crecimiento superior
        for j=1:numel(min_object)
            mask_diff = mask_diff-min_object{j};
        end
        if max(mask_diff(:))<1
            break
        end
        stats = regionprops(logical(mask_diff),'Area','PixelIdxList'); 
        area = [stats.Area];
        pixel = {stats.PixelIdxList};
        if numel(area)>1
            h=h+1;
            mask_d = 0*mask_diff;
            position = find(area==max(area),1,'last');
            mask_d(pixel{position})=1;
            mask_d = logical(mask_d);
            min_object{h} = mask_diff-mask_d;
            mask_diff = mask_d;
        end
        stats = regionprops(mask_diff,'Extrema');
        extrema = [stats.Extrema];
        height_sup(p,:) = floor(extrema(2,:));
        height_sup(p,2) = height_sup(p,2)+1;
        height_inf(p,:) = floor(extrema(5,:));    
        mask_grow = mask+mask_diff; 
        MASK{p} = mask_grow;
        if p>20 %pixel = 0.293 mm 0.293*20=5,86 mm de limite 
            break;
        end
    end
    
    %% interpolaciones 
    
    %% si el crecimiento fue en exceso
    diff_inf = diff(height_inf(:,2));
    f = find(diff_inf==1,1,'last');
    if p>15 && isempty(f)==0 %4,981 mm (en pocos casos habrá error)
        %primero puntos inferiores
        for h=f:-1:1
            if diff_inf(h)~= 1
                break
            end
        end
        %el límite inferior es facil de detectar, lo usaremos como limite
        height_inf = height_inf(1:h,:); 
        %el limite superior es más dificl
        if numel(height_sup(:,1))>numel(1:h+5) 
            height_sup = height_sup(1:h+5,:);
            [pks,locs] = findpeaks(height_sup(:,2)); %buscar el maximo local
            if isempty(pks)==0
                locs = locs(find(pks==max(pks),1,'last'));
                height_sup = height_sup(1:locs,:);
            else %si no hay maximo local cogemos el valor maximo
                locs = find(height_sup(:,2)==max(height_sup(:,2)),1,'last');
            end
        else % en los casos no comunes cogemos el limite del punto inferior
            height_sup = height_sup(1:h,:);
        end
        height = [height_sup; flipud(height_inf)];
        height1 = height(:,1); height2 = height(:,2);
        %modificamos los datos para evitar repeticiones (puede darse en
        %casos donde no hay cartilago)
        if numel(unique(height2))<numel(height2)
            h2 = sort(height2);
            pos = find(diff(h2)==0);
            POS = pos*0;
            for j=1:numel(pos)
                POS(j) = find(height2==h2(pos(j)),1,'last');
                height2(POS(j))=NaN;
            end
            height1(POS)=[]; height2(POS) = [];
        end
         pos = find(diff(height2)<0);
        if isempty(pos)==1
            
        else
            height2 = height2(1:pos);
            height1 = height1(1:pos);
        end
        %con los puntos hacemos interpolacion
        range = height2(1):height2(end);
        points = pchip(height2,height1,range);
        points = round(points);
        %y aplicamos la interpolacion a la mascara
        masked = mask;
        for j=1:numel(points)
            masked(range(j),points(j):end)=0;
        end
        
        %% si el crecimiento fue el correcto
    else
        masked = mask;
    end
    
    %% modificaciones finales, eliminar puntos de bajo valor y objetos residuales
    stats = regionprops(logical(masked),'Area','PixelIdxList');
    area = [stats.Area]; pixel = {stats.PixelIdxList};
    if numel(area)>1
        pos = find(area==max(area));
        masked = 0*masked;
        masked(pixel{pos}) = 1;
    end
    masked(im.*masked<80) = 0; % umbral de 80 es el mínimo aproximado
    stats = regionprops(logical(masked),'Area','PixelIdxList');
    area = [stats.Area]; pixel = {stats.PixelIdxList};
    if numel(area)>1
        masked = 0*masked;
        pos = find(area>0.1*max(area));
        for j=1:numel(pos)
            masked(pixel{pos(j)})=1;
        end
    end
    masked = imfill(logical(masked),'holes'); % rellenamos posibles huecos
    MASKED(:,:,i) = logical(masked);
    stats = regionprops(MASKED(:,:,i),'Eccentricity','Area');
    ECCENTRICITY(i) = stats.Eccentricity;
    AREA(i) = stats.Area;
    waitbar((i-slice1+1)/(slice2-slice1))
end
close(loadbar)
m = mean(ECCENTRICITY(ECCENTRICITY>0));
sd = std(ECCENTRICITY(ECCENTRICITY>0));
POS = find(ECCENTRICITY<m-2*sd);
POS = POS(POS<=slice2 & POS>=slice1);
Area = AREA(slice1:slice2);
Area_dif = diff(Area);
m = mean(Area_dif); sd = std(Area_dif);
p_sup = find(Area_dif>m+1.5*sd);
p_inf = find(Area_dif<m-1.5*sd)+1;
p = [p_sup;p_inf];
while isempty(p_sup)==0 && isempty(p_inf)==0
    Area_dif(p_sup) = m;
    Area_dif(p_inf) = m;
    p_sup = find(Area_dif>m+1.5*sd);
    p_inf = find(Area_dif<m-1.5*sd)+1;
    p = [p;p_sup;p_inf];
end
p = unique(p)+slice1-1;
POS = unique([POS;p]);

MASKED = stop_correction(MASKED,image_filt,image_grad,z,POS);

MASKED = logical(MASKED);
