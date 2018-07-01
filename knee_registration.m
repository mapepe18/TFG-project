function registered = knee_registration(target,reference,position)
%position es el resultado de la función reference_finder

%target es el conjunto de imágenes a registrar (array tridimensional)

%reference es conjunto de imágenes de referencia correspondientes a las
%imagenes a segmentar (array tridimensional)

%registered son las imágenes ya registradas (array tridimensional)
[optimizer,metric] = imregconfig('multimodal');

s_target = size(target);
s_reference = size(reference);
registered = zeros(s_reference(1),s_reference(2),s_target(3));
resized = registered;
if prod(s_target(1:2))< 0.9*prod(s_reference(1:2))
    loadbar = waitbar(0,'registering...');
    for i=1:s_target(3)
        resized(:,:,i) = imresize(target(:,:,i),[s_reference(1) s_reference(2)]);
        registered(:,:,i) = imregister(resized(:,:,i),reference(:,:,position(i)),'rigid',optimizer,metric);
        waitbar(i/s_target(3));
    end
    close(loadbar);
elseif prod(s_target(1:2))>0.9*prod(s_reference(1:2) & s_target(1:2))~=prod(s_reference(1:2))
    loadbar = waitbar(0,'registering...');
    for i=1:s_target(3)
        registered(:,:,i) = imregister(target(:,:,i),reference(:,:,position(i)),'similarity',optimizer,metric);
        waitbar(i/s_target(3));
    end
    close(loadbar)
else
    loadbar = waitbar(0,'registering...');
    for i=1:s_target(3)
        registered(:,:,i) = imregister(target(:,:,i),reference(:,:,position(i)),'rigid',optimizer,metric);
        waitbar(i/s_target(3));
    end
    close(loadbar)
end

figure   
for i = 0:8
    subplot(3,3,i+1)
    imshowpair(registered(:,:,round(1+i*size(registered,3)/9)),reference(:,:,position(round(1+i*size(registered,3)/9))))
end
