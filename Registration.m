function varargout = Registration(varargin)
% REGISTRATION MATLAB code for Registration.fig
%      REGISTRATION, by itself, creates a new REGISTRATION or raises the existing
%      singleton*.
%
%      H = REGISTRATION returns the handle to a new REGISTRATION or the handle to
%      the existing singleton*.
%
%      REGISTRATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REGISTRATION.M with the given input arguments.
%
%      REGISTRATION('Property','Value',...) creates a new REGISTRATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Registration_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Registration_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Registration

% Last Modified by GUIDE v2.5 21-Mar-2016 17:28:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Registration_OpeningFcn, ...
                   'gui_OutputFcn',  @Registration_OutputFcn, ...
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


% --- Executes just before Registration is made visible.
function Registration_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Registration (see VARARGIN)

% Choose default command line output for Registration
handles.output = hObject;
handles.reference = [];
handles.target = [];
handles.registered = [];
handles.buttons = [handles.target_load, handles.clear, handles.save, handles.register,...
    handles.slider1, handles.slider2, handles.slider3];
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Registration wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Registration_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load_reference.
function load_reference_Callback(hObject, eventdata, handles)
% hObject    handle to load_reference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folder = uigetdir;
directory = dir(fullfile(folder, '*.dcm'));
L = length(directory);
loadbar = waitbar(0,'Loading...');
for i = 1:L
        Image_set(:,:,i) = dicomread([folder '/' directory(i).name]);
        info{i} = dicominfo([folder '/' directory(i).name]);
        position{i} = info{i}.ImagePositionPatient;
        waitbar(i/L)
end
close(loadbar)
handles.reference = Image_set;
handles.reference_position = position;
axes(handles.axes1)
imshow(handles.reference(:,:,1),[]);
set(handles.slider1,'Max',size(handles.reference,3)) 
set(handles.slider1,'Min',1)
set(handles.slider1,'Value',1)
set(handles.slider1,'Sliderstep',[1 1]/(size(handles.reference,3)-1));
set(handles.reference_slice,'String','Slice: 1');
set(handles.buttons,'Enable','on');
guidata(hObject,handles)

% --- Executes on button press in target_load.
function target_load_Callback(hObject, eventdata, handles)
% hObject    handle to target_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

folder = uigetdir;
directory = dir(fullfile(folder, '*.dcm'));
L = length(directory);
loadbar = waitbar(0,'Loading...');
for i = 1:L
        Image_set(:,:,i) = dicomread([folder '/' directory(i).name]);
        info{i} = dicominfo([folder '/' directory(i).name]);
        position{i} = info{i}.ImagePositionPatient;
        waitbar(i/L)
end
close(loadbar)
handles.target = Image_set;
handles.target_position = position;
axes(handles.axes2);
imshow(handles.target(:,:,1),[]);
set(handles.slider2,'Max',size(handles.target,3)) 
set(handles.slider2,'Min',1)
set(handles.slider2,'Value',1)
set(handles.slider2,'Sliderstep',[1 1]/(size(handles.target,3)-1));
set(handles.target_slice,'String','Slice: 1');

guidata(hObject,handles)


% --- Executes on button press in register.
function register_Callback(hObject, eventdata, handles)
% hObject    handle to register (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.target)==1
     warndlg('You must load images to register (target)','!! Warning !!')
else
    handles.position = Reference_finder(handles.reference_position,handles.target_position);
    handles.registered = knee_registration(handles.target,handles.reference,handles.position);
    axes(handles.axes3)
    imshowpair(handles.registered(:,:,1),handles.reference(:,:,handles.position(1)));
    set(handles.slider3,'Max',size(handles.registered,3)) 
    set(handles.slider3,'Min',1)
    set(handles.slider3,'Value',1)
    set(handles.slider3,'Sliderstep',[1 1]/(size(handles.registered,3)-1));
    set(handles.registered_slice,'String','Slice: 1');
end
guidata(hObject,handles)

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
i = round(get(hObject,'Value'));
axes(handles.axes1)
imshow(handles.reference(:,:,i),[]);
set(handles.reference_slice,'String',['Slice: ' num2str(i)]);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

i = round(get(hObject,'Value'));
axes(handles.axes2)
imshow(handles.target(:,:,i),[]);
set(handles.target_slice,'String',['Slice: ' num2str(i)]);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

i = round(get(hObject,'Value'));
axes(handles.axes3)
imshowpair(handles.registered(:,:,i),handles.reference(:,:,handles.position(i)))
set(handles.registered_slice,'String',['Slice: ' num2str(i)]);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.registered)==1
    warndlg('Registration has not been applied','!! Warning !!')
else
    [FileName,PathName] = uiputfile('*.mat');
    name = FileName(1:end-4);
    s = struct(name,struct('RegisteredImages',handles.registered,'ReferencePosition',handles.position));
    save([PathName FileName],'-struct','s',name);
end
guidata(hObject,handles)

% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)
% hObject    handle to clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes1) 
cla
axes(handles.axes2)
cla
axes(handles.axes3)
cla
handles.target = []; handles.reference = []; handles.registered = [];
set(handles.reference_slice,'String','Slice:');
set(handles.target_slice,'String','Slice:')
set(handles.registered_slice,'String','Slice:')
set(handles.buttons,'Enable','off');
guidata(hObject,handles)
