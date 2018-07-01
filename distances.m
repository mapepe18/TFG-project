function [distance,skeleton3d,matrix,surface] = distances(data)

mask = data.CartilagueMasks;
width = data.PixelWidth(1);
slice1 = data.SliceLimits(1);
slice2 = data.SliceLimits(2);
%% Skeleton
distance = {};
skeleton = {};
for j=1:size(mask,3)
    a = mask(:,:,j);
    %bordes
    edges_dist = a-imerode(a,strel('square',3));
    %esqueleto
    skel = bwmorph(a,'skel',Inf);
    %puntos de las ramas y posiciones
    end_points = bwmorph(skel,'endpoints');
    [row,column] = find(end_points==1);
    [ma, ma_pos] = max(row);
    [mi, mi_pos] = min(row);
    %selección de los puntos individuales (pueden aparecer errores)
    stats = regionprops(end_points,'Area','PixelIdxList');
    area = [stats.Area];
    pixel = {stats.PixelIdxList};
    no_pixel = {};
    c = 0;
    for i=1:numel(area)
        if area(i)>1
            c = c+1;
            no_pixel{c} = pixel{i}; %puntos a mantener
        end
    end
    %generación de matriz con puntos a eliminar
    extrema = end_points*0;
    extrema(row(ma_pos),column(ma_pos)) = 1;
    extrema(row(mi_pos),column(mi_pos)) = 1;
    for i=1:numel(no_pixel)
        extrema(no_pixel{i}) = 1; %matriz de corrección de puntos a mantener
    end
    extrema = logical(extrema);
    %resta de puntos y bucle para eliminar ramas
    new_skel = skel - end_points + extrema;
    while bwarea(skel)>bwarea(new_skel)
        skel = new_skel;
        end_points = bwmorph(skel,'endpoints');
        new_skel = skel - end_points + extrema;
        stats = bwconncomp(new_skel);
        if stats.NumObjects > 1
            new_skel = skel;
            break
        end
    end
    %eliminar bordes de un lateral
    [row, column] = find(new_skel==1);
    for i=1:numel(row)
        edges_dist(row(i),1:column(i)) = 0;
    end
    %eliminar posibles puntos residuales del borde
    stats = regionprops(edges_dist,'Area','PixelIdxList');
    area = [stats.Area];
    pixel = {stats.PixelIdxList};
    if numel(area)>1
        [m,m_pos] = max(area);
        edges_dist = edges_dist*0;
        edges_dist(pixel{m_pos}) = 1;
    end
    edges_dist = logical(edges_dist);
    %bordes por la imagen distancia al esqueleto(+1 por el grosor del
    %esqueleto y producto por las dimensiones del pixel
    
    dis = (edges_dist.*bwdist(new_skel));
    dis(dis>0) = dis(dis>0)+1;
    dis(edges_dist==1 & bwdist(new_skel)==0) = 1;
    dis = dis*width*2;
    surface(:,:,j) = dis;
    skeleton3d(:,:,j) = new_skel;
    dis = dis';
    dis = dis(dis>0);
    distance{j} = dis;
    skeleton{j} = new_skel;
end
[max_size, max_index] = max(cellfun('size', distance, 1));

matrix = zeros(max_size,slice2-slice1+1);
for i=slice1:slice2
    matrix(1:numel(distance{i}),i-slice1+1) = distance{i};
    matrix(1:numel(distance{i}),i-slice1+1) = distance{i};
end
% imshow(matrix,[])
% truesize([512 512])
    



    

