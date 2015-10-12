function varargout = make_zstackView(varargin)
% MAKE_ZSTACKVIEW MATLAB code for make_zstackView.fig
%      MAKE_ZSTACKVIEW, by itself, creates a new MAKE_ZSTACKVIEW or raises the existing
%      singleton*.
%
%      H = MAKE_ZSTACKVIEW returns the handle to a new MAKE_ZSTACKVIEW or the handle to
%      the existing singleton*.
%
%      MAKE_ZSTACKVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAKE_ZSTACKVIEW.M with the given input arguments.
%
%      MAKE_ZSTACKVIEW('Property','Value',...) creates a new MAKE_ZSTACKVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before make_zstackView_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to make_zstackView_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help make_zstackView

% Last Modified by GUIDE v2.5 02-Oct-2015 15:35:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @make_zstackView_OpeningFcn, ...
                   'gui_OutputFcn',  @make_zstackView_OutputFcn, ...
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


% --- Executes just before make_zstackView is made visible.
function make_zstackView_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to make_zstackView (see VARARGIN)

% Choose default command line output for make_zstackView
handles.output = hObject;

handles.imageMeanStack=varargin{1}.frameMeanMaster;
handles.imageCorrStack=varargin{1}.frameCorrMaster;

% switch handles.image_popup.Value
%     case 1
        handles.baseimage = handles.imageMeanStack(:,:,1);
%     case 2
%         handles.baseimage = handles.imageCorrStack(:,:,1);
% end

handles.corrimage = handles.imageCorrStack(:,:,1);

handles.frameSlider.Max=size(handles.imageMeanStack,3);
handles.frameSlider.SliderStep=[1/(handles.frameSlider.Max-1) 1/(handles.frameSlider.Max-1)];
handles.frameSliderIndicator.String=1;
handles.nowFrame=1;
axes(handles.bigAxes);

%initialize brightness and contrast
handles.contrastSlider.Value = 1./(max(max(handles.baseimage))-min(min(handles.baseimage)));
handles.brightSlider.Value = 1/2*(1-(max(max(handles.baseimage))+min(min(handles.baseimage)))/(max(max(handles.baseimage))-min(min(handles.baseimage))));

handles.contrastSlider.Max = 10*handles.contrastSlider.Value;
handles.contrastSlider.Min = 1/10*handles.contrastSlider.Value;

handles.brightSlider.Min = -1;
handles.brightSlider.Max = 1;

handles.brightness_txt.String = handles.brightSlider.Value;
handles.contrast_txt.String = handles.contrastSlider.Value;

handles.baseimageRGB = handles.baseimage*handles.contrastSlider.Value+handles.brightSlider.Value;
handles.baseimageRGB = repmat(handles.baseimageRGB,[1,1,3]);

handles.ref_image=image(handles.baseimageRGB);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes make_zstackView wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = make_zstackView_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function frameSlider_Callback(hObject, eventdata, handles)
% hObject    handle to frameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.bigAxes);
handles.nowFrame=ceil(handles.frameSlider.Value);

% switch handles.image_popup.Value
%     case 1
try
handles.baseimage=handles.imageMeanStack(:,:,handles.nowFrame);
catch
    disp('')
end
%     case 2
%         handles.baseimage=handles.imageCorrStack(:,:,handles.nowFrame);
% end

handles.frameSlider.Max=size(handles.imageMeanStack,3);
handles.frameSliderIndicator.String=handles.nowFrame;

handles.baseimageRGB = handles.baseimage*handles.contrastSlider.Value+handles.brightSlider.Value;
handles.baseimageRGB = repmat(handles.baseimageRGB,[1,1,3]);

handles.ref_image.CData=handles.baseimageRGB;
set(handles.ref_image,'ButtonDownFcn',{@ImageClickCallback,handles});
   
guidata(hObject, handles);
    
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function frameSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function brightSlider_Callback(hObject, eventdata, handles)
% hObject    handle to brightSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    axes(handles.bigAxes);
    handles.bright_txt.String = handles.brightSlider.Value;

    handles.baseimageRGB = handles.baseimage*handles.contrastSlider.Value+handles.brightSlider.Value;
    handles.baseimageRGB = repmat(handles.baseimageRGB,[1,1,3]);
    handles.ref_image.CData=handles.baseimageRGB;
    
    guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function brightSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to brightSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function brightness_txt_Callback(hObject, eventdata, handles)
% hObject    handle to brightness_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of brightness_txt as text
%        str2double(get(hObject,'String')) returns contents of brightness_txt as a double


% --- Executes during object creation, after setting all properties.
function brightness_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to brightness_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function contrastSlider_Callback(hObject, eventdata, handles)
% hObject    handle to contrastSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    axes(handles.bigAxes);
    handles.contrast_txt.String = handles.contrastSlider.Value;

    handles.baseimageRGB = handles.baseimage*handles.contrastSlider.Value+handles.brightSlider.Value;
    handles.baseimageRGB = repmat(handles.baseimageRGB,[1,1,3]);
    handles.ref_image.CData=handles.baseimageRGB;
    
    guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function contrastSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contrastSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function contrast_txt_Callback(hObject, eventdata, handles)
% hObject    handle to contrast_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of contrast_txt as text
%        str2double(get(hObject,'String')) returns contents of contrast_txt as a double


% --- Executes during object creation, after setting all properties.
function contrast_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contrast_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
