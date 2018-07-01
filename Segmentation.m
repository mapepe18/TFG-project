function varargout = Segmentation(varargin)
% SEGMENTATION MATLAB code for Segmentation.fig
%      SEGMENTATION, by itself, creates a new SEGMENTATION or raises the existing
%      singleton*.
%
%      H = SEGMENTATION returns the handle to a new SEGMENTATION or the handle to
%      the existing singleton*.
%
%      SEGMENTATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGMENTATION.M with the given input arguments.
%
%      SEGMENTATION('Property','Value',...) creates a new SEGMENTATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Segmentation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Segmentation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Segmentation

% Last Modified by GUIDE v2.5 12-Mar-2016 18:48:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Segmentation_OpeningFcn, ...
                   'gui_OutputFcn',  @Segmentation_OutputFcn, ...
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


% --- Executes just before Segmentation is made visible.
function Segmentation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Segmentation (see VARARGIN)

% Choose default command line output for Segmentation
handles.output = hObject;
handles.afterload = [handles.segment, handles.slice_first, handles.slice_last,...
    handles.slider1, handles.number, handles.first_number, handles.last_number];
handles.aftersegment = [handles.popupmenu1, handles.save, handles.clear_correct,...
    handles.fill, handles.delete_fragment];
set(handles.afterload,'Enable','off');
set(handles.aftersegment,'Enable','off');
handles.option = 'Image';
handles.mask = [];
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Segmentation wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Segmentation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.aftersegment,'Enable','off');
folder = uigetdir;
directory = dir(fullfile(folder, '*.dcm'));
L = length(directory);
loadbar = waitbar(0,'Loading...');
for i = 1:L
        Image_set(:,:,i) = dicomread([folder '/' directory(i).name]);
        waitbar(i/L)
end
info = dicominfo([folder '/' directory(1).name]);
handles.thickness = info.SliceThickness;
handles.pixelwidth = info.PixelSpacing;
close(loadbar)
set(handles.afterload,'Enable','on');
handles.image = Image_set;
set(handles.number,'String','Slice: 1');
axes(handles.axes1)
imshow(Image_set(:,:,1),[]);
set(handles.slider1,'Max',size(Image_set,3)) 
set(handles.slider1,'Min',1)
set(handles.slider1,'Value',1)
set(handles.slider1,'Sliderstep',[1 1]/(size(handles.image,3)-1));
set(handles.first_number,'String','First slice: ');
set(handles.last_number,'String','Last slice: ');
handles.first = [];
handles.last = [];
handles.mask = [];
handles.option = 'Image';
set(handles.popupmenu1,'Value',1);
clear('handles.mask');

guidata(hObject,handles);



% --- Executes on button press in segment.
function segment_Callback(hObject, eventdata, handles)
% hObject    handle to segment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.first)==1 || isempty(handles.last)==1
    warndlg('You must select slice limits','!! Warning !!')
else
   [MASKED,image_filt] = patelar_cartilague_segmentation(handles.image,handles.first,handles.last);
    set(handles.aftersegment,'Enable','on');
    i = round(get(handles.slider1,'Value'));
    handles.mask = MASKED;
    handles.image = image_filt;
    axes(handles.axes1)
    imshowpair(handles.mask(:,:,i),handles.image(:,:,i),'blend');
    set(handles.popupmenu1,'Value',3);
    handles.option = 'Image-Mask';

end

guidata(hObject,handles);

% --- Executes on button press in slice_first.
function slice_first_Callback(hObject, eventdata, handles)
% hObject    handle to slice_first (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
i = round(get(handles.slider1,'Value'));
handles.first = i;
set(handles.first_number,'String',['First slice: ' num2str(i)]);

guidata(hObject,handles)


% --- Executes on button press in slice_last.
function slice_last_Callback(hObject, eventdata, handles)
% hObject    handle to slice_last (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
i = round(get(handles.slider1,'Value'));
handles.last = i;
set(handles.last_number,'String',['Last slice: ' num2str(i)]);

guidata(hObject,handles)


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
i = round(get(hObject,'Value'));
if strcmp(handles.option,'Image') == 1
    axes(handles.axes1)
    imshow(handles.image(:,:,i),[]);
elseif strcmp(handles.option,'Mask') == 1
    axes(handles.axes1)
    imshow(handles.mask(:,:,i),[]);
elseif strcmp(handles.option,'Image-Mask') == 1
    axes(handles.axes1)
    imshowpair(double(handles.mask(:,:,i)),handles.image(:,:,i),'blend');
end
set(handles.number,'String',['Slice:' num2str(i)]);
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


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
contents = cellstr(get(hObject,'String'));
handles.option = contents{get(hObject,'Value')};
i = round(get(handles.slider1,'Value'));
if strcmp(handles.option,'Image') == 1
    axes(handles.axes1)
    imshow(handles.image(:,:,i),[]);
elseif strcmp(handles.option,'Mask') == 1
    axes(handles.axes1)
    imshow(handles.mask(:,:,i),[]);
elseif strcmp(handles.option,'Image-Mask') == 1
    axes(handles.axes1)
    imshowpair(handles.mask(:,:,i),handles.image(:,:,i),'blend');
end

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.first)==1 || isempty(handles.last)==1
    warndlg('You must select slice limits','!! Warning !!')
elseif isempty(handles.mask)==1
    warndlg('Segmentation has not been applied','!! Warning !!')
else
%     folder = uigetdir;
    if handles.first>1
        handles.mask(:,:,handles.first-1:-1:1) = 0;
    else
        handles.mask(:,:,1) = 0;
    end
    if handles.last<size(handles.mask,3)
        handles.mask(:,:,handles.last+1:end) = 0;
    else
        handles.mask(:,:,end) = 0;
    end
%     Data = struct('CartilagueMasks',handles.mask,'SliceLimits',[handles.first handles.last]);
%     save([folder '\' 'Data'],'Data')
    [FileName,PathName] = uiputfile('*.mat');
    name = FileName(1:end-4);
    Data = struct(name,struct('CartilagueMasks',handles.mask,'SliceLimits',[handles.first handles.last],...
                              'Thickness',handles.thickness,'PixelWidth',handles.pixelwidth));
    save([PathName FileName],'-struct','Data',name);
end
    

guidata(hObject,handles)


% --- Executes on button press in clear_correct.
function clear_correct_Callback(hObject, eventdata, handles)
% hObject    handle to clear_correct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.popupmenu1,'Enable','off');
i = round(get(handles.slider1,'Value'));
handles.mask(:,:,i) = 0*handles.mask(:,:,i);
axes(handles.axes1)
imshow(handles.image(:,:,i),[]);
h = imfreehand;
handles.mask(:,:,i) = imfill(createMask(h),'holes');
axes(handles.axes1)
imshowpair(handles.mask(:,:,i),handles.image(:,:,i),'blend')
set(handles.popupmenu1,'Enable','on');

guidata(hObject,handles)

% --- Executes on button press in fill.
function fill_Callback(hObject, eventdata, handles)
% hObject    handle to fill (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.popupmenu1,'Enable','off')
i = round(get(handles.slider1,'Value'));
axes(handles.axes1)
imshowpair(handles.mask(:,:,i),handles.image(:,:,i),'blend')
h = imfreehand;
h = createMask(h);
handles.mask(:,:,i) = logical(handles.mask(:,:,i) + h);
handles.mask(:,:,i) = imfill(handles.mask(:,:,i),'holes');
axes(handles.axes1)
imshowpair(handles.mask(:,:,i),handles.image(:,:,i),'blend')
set(handles.popupmenu1,'Enable','on')

guidata(hObject,handles)

% --- Executes on button press in delete_fragment.
function delete_fragment_Callback(hObject, eventdata, handles)
% hObject    handle to delete_fragment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.popupmenu1,'Enable','off')
i = round(get(handles.slider1,'Value'));
axes(handles.axes1)
imshowpair(handles.mask(:,:,i),handles.image(:,:,i),'blend')
h = imfreehand;
h = createMask(h);
h = handles.mask(:,:,i).*h;
handles.mask(:,:,i) = logical(handles.mask(:,:,i) - h);
axes(handles.axes1)
imshowpair(handles.mask(:,:,i),handles.image(:,:,i),'blend')
set(handles.popupmenu1,'Enable','on')

guidata(hObject,handles)
