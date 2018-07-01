function varargout = Visualization(varargin)
% VISUALIZATION MATLAB code for Visualization.fig
%      VISUALIZATION, by itself, creates a new VISUALIZATION or raises the existing
%      singleton*.
%
%      H = VISUALIZATION returns the handle to a new VISUALIZATION or the handle to
%      the existing singleton*.
%
%      VISUALIZATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VISUALIZATION.M with the given input arguments.
%
%      VISUALIZATION('Property','Value',...) creates a new VISUALIZATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Visualization_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Visualization_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Visualization

% Last Modified by GUIDE v2.5 21-Mar-2016 15:30:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Visualization_OpeningFcn, ...
                   'gui_OutputFcn',  @Visualization_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Visualization is made visible.
function Visualization_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Visualization (see VARARGIN)

% Choose default command line output for Visualization
handles.output = hObject;
set(handles.slider1,'Sliderstep',[1 1]/(10));
set(handles.slider2,'Sliderstep',[1 1]/(10));
handles.button = [handles.clear, handles.load_study_t1, handles.load_study_t2,handles.results_t1...
                  handles.results_t2, handles.save_t1, handles.save_t2];
handles.volume_t1 = [];
handles.volume_t2 = [];
handles.savevol_t1 = [];
handles.savevol_t2 = [];
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Visualization wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Visualization_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

i = get(hObject,'Value');
map = ones(120,1); map(1) = 0;
if i==0
    map(:) = 1;
    map(1) = 0;
    alphamap(handles.axes2,map)
else
    map = map * (1-i);
    alphamap(handles.axes2,map);
end
set(handles.transparency1,'String',['Transparency: ' num2str(i)])
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in load_mask.
function load_mask_Callback(hObject, eventdata, handles)
% hObject    handle to load_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile;
X = load([pathname filename]);
data = X.(filename(1:end-4));
clear 'X';
handles.mask = data.CartilagueMasks;
handles.slices = data.SliceLimits;
handles.thickness = data.Thickness;
handles.pixel = data.PixelWidth;
stats = regionprops(handles.mask,'Area','BoundingBox');
handles.bounds = floor([stats.BoundingBox]);
b = handles.bounds;
area = stats.Area;
handles.number_slice = size(handles.mask,3);
handles.mask = handles.mask(b(2):b(2)+b(2+3),b(1):b(1)+b(1+3),:);
area = area*prod(handles.pixel); %(superficies mm2)
volume = area * handles.thickness; %volumen mm3
volume = volume/1000; %cm3
%en dicom: 'Slice Thickness' 'Pixel Spacing'
figure
mask = handles.mask;
mask = mask(:,:,b(3)-1:b(3)+b(3+3)+1);
mask = permute(mask,[3 2 1]);
handles.permuted_mask = mask;
mask = smooth3(mask,'box');
isosurface(mask)
% daspect([1 1 0.293/2])
daspect([1 0.293/2  1])
xlabel('Eje Anterioposterior','FontSize',10)
ylabel('Eje Izquierda-derecha','Fontsize',10)
zlabel('Eje Craneocaudal','Fontsize',10)
set(gca,'ylim',[1 size(mask,1)]);
set(gca,'xlim',[1 size(mask,2)+5]);
set(gca,'zlim',[1 size(mask,3)]);
posy = get(gca, 'YTick');
posx = get(gca, 'XTick');
posz = get(gca, 'ZTick');
height = 0.293*2;
height = height*posy; 
height = height';
row = 0.293*posz; col = 0.293*posx;
row = row'; col = col';
labely = num2str(round(row));
labelx = num2str(round(col));
labelz = num2str(round(height));
set(gca, 'YTickLabel', labely); 
set(gca, 'XTickLabel', labelx);
set(gca,'ZTickLabel', labelz);
view(3);
colormap(jet)
camlight;
set(handles.vol,'String',['Volume: ' num2str(volume) ' cm3']);
set(handles.button,'Enable','on');

[distance,skeleton,matrix,surface] = distances(data);
surface_new = surface;
surface_new = surface_new(b(2):b(2)+b(2+3),b(1):b(1)+b(1+3),b(3)-1:b(3)+b(3+3)+1);
skeleton = skeleton(b(2):b(2)+b(2+3),b(1):b(1)+b(1+3),b(3)-1:b(3)+b(3+3)+1);
surface_new = permute(surface_new,[3 2 1]);
% skeleton = permute(skeleton,[3 2 1]);
% distance = bwdist(skeleton);
% distance = distance/max(distance(:));
% distance = 1 - distance;
% distance = distance.*mask;
% distance_min = min(distance(distance>0));
% distance = 0.1 + (1-0.1)*(distance-distance_min)./(1-distance_min);
% distance(distance<0) = 0;

skeleton = permute(skeleton,[3 2 1]);
distance = skeleton*0;
for j=1:size(skeleton,3)
    d = bwdist(skeleton(:,:,j));
    d = d/max(d(:));
    d = 1 - d;
    d = d.*mask(:,:,j);
    distance_min = min(d(d>0));
    if isempty(distance_min) == 0
        d = 0.1 + (1-0.1)*(d-distance_min)./(1-distance_min);
        d(d<0) = 0;
        distance(:,:,j) = d;
    else
        distance(:,:,j) = 0;
    end
 
end

handles.distance = distance;
surface_news = surface_new*0;
surface_news(:,end:end+5,:) = 0;
surface_news(:,5+1:end,:) = surface_new;
surface_new = surface_news;
figure
title('Mapa de espesor')
vol3d('CData',surface_new);
colorbar
map = ones(120,1); map(1) = 0; 
handles.map = map;

alphamap(map)
% daspect([1 1 0.293/2])
daspect([1 0.293/2  1])
view(3)

guidata(hObject,handles)

% --- Executes on button press in load_study_t1.
function load_study_t1_Callback(hObject, eventdata, handles)
% hObject    handle to load_study_t1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile;
X = load([pathname filename]);
data = X.(filename(1:end-4));
handles.t1_name = filename(1:end-4);
set(handles.text5,'String',filename(1:end-4))
position = data.ReferencePosition;
volume = data.RegisteredImages;
b = handles.bounds;
t1_slice = size(volume,3);
volume = volume(b(2):b(2)+b(2+3),b(1):b(1)+b(1+3),:);

for i=1:numel(position)
    volume(:,:,i) = volume(:,:,i).*handles.mask(:,:,position(i));
end
handles.volume_t1 = volume;
if handles.number_slice > t1_slice
    ratio = handles.number_slice/t1_slice;
    [rows,cols,slices] = size(volume);
    [X,Y,Z] = meshgrid(1:cols, 1:rows, 1:slices);
    [X2,Y2,Z2] = meshgrid(1:cols, 1:rows, 1/ratio:1/ratio:slices);
    volume = interp3(X, Y, Z, volume, X2, Y2, Z2, 'linear', 0);
    vol = smooth3(volume,'box',[9 9 9]);
else
    vol = smooth3(volume,'box',[7 7 7]);
end
vol = vol(:,:,b(3)-1:b(3)+b(3+3)+1);
axes(handles.axes2)
cla
vol = permute(vol,[3 2 1]);
vol = vol.*handles.permuted_mask;
handles.volt1 = vol;
vol3d('cdata',vol)
xlabel('Eje Anterioposterior','FontSize',10)
ylabel('Eje Izquierda-derecha','Fontsize',10)
zlabel('Eje Craneocaudal','Fontsize',10)
daspect([1 0.293/2 1])
set(gca,'ylim',[1 size(vol,1)]);
set(gca,'xlim',[1 size(vol,2)]);
set(gca,'zlim',[1 size(vol,3)]);
posy = get(gca, 'YTick');
posx = get(gca, 'XTick');
posz = get(gca, 'ZTick');
height = 0.293*2;
height = height*posy; 
height = height';
row = 0.293*posz; col = 0.293*posx;
row = row'; col = col';
labely = num2str(round(row));
labelx = num2str(round(col));
labelz = num2str(round(height));
set(gca, 'YTickLabel', labely); 
set(gca, 'XTickLabel', labelx);
set(gca,'ZTickLabel', labelz);
view(3);
map = ones(120,1);
map(1) = 0;
alphamap(handles.axes2,map)
colormap(handles.axes2,jet)
colorbar
set(handles.slider1,'Value',0);
set(handles.transparency1,'String','Transparency: 0');

guidata(hObject,handles)

% --- Executes on button press in load_study_t2.
function load_study_t2_Callback(hObject, eventdata, handles)
% hObject    handle to load_study_t2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile;
X = load([pathname filename]);
handles.t2_name = filename(1:end-4);
set(handles.text6,'String',filename(1:end-4));
data = X.(filename(1:end-4));
position = data.ReferencePosition;
volume = data.RegisteredImages;
b = handles.bounds;
t2_slice = size(volume,3);
volume = volume(b(2):b(2)+b(2+3),b(1):b(1)+b(1+3),:);
for i=1:numel(position)
    volume(:,:,i) = volume(:,:,i).*handles.mask(:,:,position(i));
end
handles.volume_t2 = volume;
if handles.number_slice > t2_slice
    ratio = handles.number_slice/t2_slice;
    [rows,cols,slices] = size(volume);
    [X,Y,Z] = meshgrid(1:cols, 1:rows, 1:slices);
    [X2,Y2,Z2] = meshgrid(1:cols, 1:rows, 1/ratio:1/ratio:slices);
    volume = interp3(X, Y, Z, volume, X2, Y2, Z2, 'linear', 0);
    vol = smooth3(volume,'box',[9 9 9]);
else
    vol = smooth3(volume,'box',[7 7 7]);
end
vol = vol(:,:,b(3)-1:b(3)+b(3+3)+1);
axes(handles.axes3);
cla
vol = permute(vol,[3 2 1]);
vol = vol.*handles.permuted_mask;
vol3d('cdata', vol,'gaussian');
xlabel('Eje Anterioposterior','FontSize',10)
ylabel('Eje Izquierda-derecha','Fontsize',10)
zlabel('Eje Craneocaudal','Fontsize',10)
daspect([1 0.293/2 1])
set(gca,'ylim',[1 size(vol,1)]);
set(gca,'xlim',[1 size(vol,2)]);
set(gca,'zlim',[1 size(vol,3)]);
posy = get(gca, 'YTick');
posx = get(gca, 'XTick');
posz = get(gca, 'ZTick');
height = 0.293*2;
height = height*posy; 
height = height';
row = 0.293*posz; col = 0.293*posx;
row = row'; col = col';
labely = num2str(round(row));
labelx = num2str(round(col));
labelz = num2str(round(height));
set(gca, 'YTickLabel', labely); 
set(gca, 'XTickLabel', labelx);
set(gca,'ZTickLabel', labelz);
view(3);
map = ones(120,1); map(1) = 0;
alphamap(handles.axes3,map)
colormap(handles.axes3,jet)
colorbar
set(handles.slider2,'Value',0);
set(handles.transparency2,'String','Transparency: 0');
handles.volt2 = vol;
guidata(hObject,handles)

% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)
% hObject    handle to clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes2)
cla
axes(handles.axes3)
cla
handles.mask = [];handles.bounds = [];handles.thickness = [];handles.pixel = [];
set(handles.vol,'String','Volume: ');
set(handles.button,'Enable','off');
set (handles.text5,'String','Study 1');
set(handles.text6,'String','Study 2');
handles.volume_t1 = [];
handles.volume_t2 = [];
handles.savevol_t1 = [];
handles.savevol_t2 = [];
guidata(hObject,handles)


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

i = get(hObject,'Value');
map = ones(30,1); map(1) = 0;
if i==0
    alphamap(handles.axes3,map);
else
    map = map*(1-i);
    alphamap(handles.axes3,map)
end
set(handles.transparency2,'String',['Transparency: ' num2str(i)])
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in results_t1.
function results_t1_Callback(hObject, eventdata, handles)
% hObject    handle to results_t1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.volume_t1)==1
      warndlg('You must load a study','!! Warning !!')
else
      volume = handles.volume_t1;
      volume = volume(volume>0);
      figure
      boxplot(volume(:));
      title([handles.t1_name '  Boxplot']);
      figure
      histogram(volume(:),'Normalization','Probability','NumBins',20)
      title([handles.t1_name '  Probability  Distribution'])
      handles.savevol_t1 = volume;
end

guidata(hObject,handles)

% --- Executes on button press in results_t2.
function results_t2_Callback(hObject, eventdata, handles)
% hObject    handle to results_t2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.volume_t2)==1
    warndlg('You must load a study','!! Warning !!')
else
    volume = handles.volume_t2;
    volume = volume(volume>0);
    figure
    boxplot(volume(:))
    title([handles.t2_name '  Boxplot']);
    figure
    histogram(volume(:),'Normalization','Probability','NumBins',20)
    title([handles.t2_name '  Probability  Distribution'])
    handles.savevol_t2 = volume;
end
guidata(hObject,handles)

% --- Executes on button press in save_t1.
function save_t1_Callback(hObject, eventdata, handles)
% hObject    handle to save_t1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.savevol_t1)==1
    warndlg('You must apply analysis','!! Warning !!')
else
    [FileName,PathName] = uiputfile('*.mat');
    name = FileName(1:end-4);
    s = struct(name,struct('Data',handles.savevol_t1));
    save([PathName FileName],'-struct','s',name);
end
guidata(hObject,handles)


% --- Executes on button press in save_t2.
function save_t2_Callback(hObject, eventdata, handles)
% hObject    handle to save_t2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.savevol_t2)==1
      warndlg('You must apply analysis','!! Warning !!')
else
    [FileName,PathName] = uiputfile('*.mat');
    name = FileName(1:end-4);
    s = struct(name,struct('Data',handles.savevol_t2));
    save([PathName FileName],'-struct','s',name);
end
guidata(hObject,handles)
