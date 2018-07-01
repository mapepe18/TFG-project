function varargout = KneeStudy(varargin)
% KNEESTUDY MATLAB code for KneeStudy.fig
%      KNEESTUDY, by itself, creates a new KNEESTUDY or raises the existing
%      singleton*.
%
%      H = KNEESTUDY returns the handle to a new KNEESTUDY or the handle to
%      the existing singleton*.
%
%      KNEESTUDY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KNEESTUDY.M with the given input arguments.
%
%      KNEESTUDY('Property','Value',...) creates a new KNEESTUDY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before KneeStudy_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to KneeStudy_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help KneeStudy

% Last Modified by GUIDE v2.5 21-Mar-2016 18:37:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @KneeStudy_OpeningFcn, ...
                   'gui_OutputFcn',  @KneeStudy_OutputFcn, ...
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


% --- Executes just before KneeStudy is made visible.
function KneeStudy_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to KneeStudy (see VARARGIN)

% Choose default command line output for KneeStudy
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes KneeStudy wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = KneeStudy_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in registration.
function registration_Callback(hObject, eventdata, handles)
% hObject    handle to registration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Registration


% --- Executes on button press in segmentation.
function segmentation_Callback(hObject, eventdata, handles)
% hObject    handle to segmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Segmentation

% --- Executes on button press in visualization.
function visualization_Callback(hObject, eventdata, handles)
% hObject    handle to visualization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Visualization
