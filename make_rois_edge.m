function varargout = make_rois_edge(varargin)
% MAKE_ROIS_EDGE MATLAB code for make_rois_edge.fig
%      MAKE_ROIS_EDGE, by itself, creates a new MAKE_ROIS_EDGE or raises the existing
%      singleton*.
%
%      H = MAKE_ROIS_EDGE returns the handle to a new MAKE_ROIS_EDGE or the handle to
%      the existing singleton*.
%
%      MAKE_ROIS_EDGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAKE_ROIS_EDGE.M with the given input arguments.
%
%      MAKE_ROIS_EDGE('Property','Value',...) creates a new MAKE_ROIS_EDGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before make_rois_edge_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to make_rois_edge_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help make_rois_edge

% Last Modified by GUIDE v2.5 02-Aug-2015 09:39:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @make_rois_edge_OpeningFcn, ...
                   'gui_OutputFcn',  @make_rois_edge_OutputFcn, ...
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


% --- Executes just before make_rois_edge is made visible.
function make_rois_edge_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to make_rois_edge (see VARARGIN)

% Choose default command line output for make_rois_edge
handles.output = hObject;

if numel(varargin{1})>0
    handles.imageStack=varargin{1};
    handles.baseimage=handles.imageStack(:,:,1);
    handles.frameSlider.Max=size(handles.imageStack,3);
    handles.frameSlider.SliderStep=[1/handles.frameSlider.Max 1/handles.frameSlider.Max];
    handles.frameSliderIndicator.String=1;
    handles.nowFrame=1;
    axes(handles.bigAxes);
    handles.baseimageRGB=handles.baseimage-min(handles.baseimage(:));
    handles.baseimageRGB=handles.baseimageRGB./max(handles.baseimageRGB(:));
    handles.baseimageRGB=repmat(handles.baseimageRGB,[1,1,3]);

    %%% at the back -- just to keep track
    handles.rois=imagesc(zeros(size(handles.baseimage,1),size(handles.baseimage,2),1));hold on;
    %%% second layer -- reference image
    handles.ref_image=image(handles.baseimageRGB);
    %%% top layer -- for presantatation popurses
    handles.roi_image=image(zeros(size(handles.baseimage,1),size(handles.baseimage,2),3));axis off
    handles.roi_image.AlphaData=handles.roi_image.CData(:,:,1)==1;


    handles.test_val=0;
    handles.LastCoorCalled=[0 0];
    winSize=cell2mat(textscan(handles.smallWinSize.String,'%f'));

    axes(handles.topAxes);
    smallFrame=handles.baseimage(1:winSize(1),1:winSize(2));
    handles.top_image=imagesc(smallFrame);axis off
    colormap('gray')

    axes(handles.lowAxes);
    smallFrame=smallFrame-min(smallFrame(:));
    smallFrame=smallFrame./max(smallFrame(:));
    smallFrameRgb=repmat(smallFrame,[1,1,3]);
    handles.low_image=image(smallFrameRgb);axis off

end

if numel(varargin)>1%% if loading roi file
  
    handles.rois.CData=varargin{2};
    unique(handles.rois.CData) 
    handles.roi_num.String=num2str(max(unique(handles.rois.CData)));
    roi_num=str2double(handles.roi_num.String);

    handles.roi_image.CData(:,:,1)=handles.rois.CData>0;
    handles.roi_image.AlphaData=handles.rois.CData>0;
    handles.roiList.String=[1:roi_num]';

end

% Update handles structure
guidata(hObject, handles);
set(handles.figure1,'KeyPressFcn',@setcallbacks);
set(handles.figure1,'WindowScrollWheelFcn',{@figScroll,handles});

handles.mask=[];
set(handles.roi_image,'ButtonDownFcn',{@ImageClickCallback,handles});


function figScroll(src,evnt,handles)
    if evnt.VerticalScrollCount==1
        if handles.frameSlider.Value<size(handles.imageStack,3)
            handles.frameSlider.Value=handles.frameSlider.Value+1;
        end
    else
        if handles.frameSlider.Value>1
            handles.frameSlider.Value=handles.frameSlider.Value-1;
        end
    end
    frameSlider_Callback(src,1,handles);

% end

function setcallbacks(src,evnt)
    handles = guidata(src);
    hObject = handles.output;
    switch evnt.Key
        case 'f'
            handles.fillCell.Value=~(handles.fillCell.Value);
            mathod_smallWinCenter( hObject , evnt ,handles);
            guidata(hObject, handles);
        case 'd'
            handles.dilateCell.Value=~(handles.dilateCell.Value);
            mathod_smallWinCenter( hObject , evnt ,handles);
            guidata(hObject, handles);
        case 'a'
            add_roi_Callback(hObject,0, handles);
        case 'escape'
        case '1'
            if handles.trsh.Value-.02>str2double(handles.trsh_min.String)
               handles.trsh.Value=handles.trsh.Value-.02;
               handles.trsh_val.String=handles.trsh.Value;
               mathod_smallWinCenter(src,1,handles)
            end
        case '2'
            if handles.trsh.Value+.02<str2double(handles.trsh_max.String)
               handles.trsh.Value=handles.trsh.Value+.02;
               handles.trsh_val.String=handles.trsh.Value;
               mathod_smallWinCenter(src,1,handles)
            end
    end;

% UIWAIT makes make_rois_edge wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = make_rois_edge_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in roiList.
function roiList_Callback(hObject, eventdata, handles)
% hObject    handle to roiList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.roi_image.CData(:,:,2)=0;
handles.roiList.Value;
handles.roi_image.CData(:,:,2)=(handles.rois.CData==handles.roiList.Value)+0;
% Hints: contents = cellstr(get(hObject,'String')) returns roiList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from roiList


% --- Executes during object creation, after setting all properties.
function roiList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roiList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in add_roi.
function add_roi_Callback(hObject, eventdata, handles)
% hObject    handle to add_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    %%% dont allow if coor were not change from last add roi call
    if ~all(handles.coor==handles.LastCoorCalled)

        handles.LastCoorCalled=handles.coor;

        handles.mask=handles.low_image.CData(:,:,1);
        handles.roi_num.String=str2double(handles.roi_num.String)+1;
        roi_num=str2double(handles.roi_num.String);

        winSize=cell2mat(textscan(handles.smallWinSize.String,'%f'));
        winInd{1}=handles.coor(1)-round(winSize(1)/2)+1:handles.coor(1)+round(winSize(1)/2);
        winInd{2}=handles.coor(2)-round(winSize(2)/2)+1:handles.coor(2)+round(winSize(2)/2);
        winInd{1}(winInd{1}<0 | winInd{1}>size(handles.baseimage,1))=[];
        winInd{2}(winInd{2}<0 | winInd{2}>size(handles.baseimage,2))=[];

        bigmask=zeros(size(handles.baseimage));
        bigmask(winInd{1}(1):winInd{1}(end),winInd{2}(1):winInd{2}(end))=handles.mask*roi_num;

        %%% zero the overlapping indices to prevent overlap
        handles.rois.CData(bigmask>0)=0;
        %%% place the indices in place
        handles.rois.CData=handles.rois.CData+bigmask;
        handles.roi_image.CData(:,:,1)=handles.rois.CData>0;
        handles.roi_image.AlphaData=handles.rois.CData>0;

        handles.roiList.String=[1:roi_num]';
        guidata(hObject, handles);

        unique(handles.rois.CData)
    end



% --- Executes on button press in delete_roi.
function delete_roi_Callback(hObject, eventdata, handles)
% hObject    handle to delete_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    %%% deleting roi
    handles.rois.CData(handles.rois.CData==handles.roiList.Value)=0;%%% deleting roi
    %%% adjusting indices of roi
    handles.rois.CData(handles.rois.CData>handles.roiList.Value)=handles.rois.CData(handles.rois.CData>handles.roiList.Value)-1;
    % roi list
    handles.roiList.String(end)=[];
    handles.roiList.Value=1;

    % delete the selected roi red mark
    handles.roi_image.CData(:,:,1)=handles.roi_image.CData(:,:,1).*(handles.rois.CData>0);%
    handles.roi_image.CData(:,:,2)=0;%% delete the selected roi mark
    handles.roi_image.AlphaData=(handles.rois.CData>0);

    handles.roi_num.String=str2double(handles.roi_num.String)-1;



% --- Executes on button press in update_roi.
function update_roi_Callback(hObject, eventdata, handles)
% hObject    handle to update_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_2_WS.
function save_2_WS_Callback(hObject, eventdata, handles)
% hObject    handle to save_2_WS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    rois=handles.rois.CData;
    assignin('base','rois',rois)

% --- Executes on button press in load_rois.
function load_rois_Callback(hObject, eventdata, handles)
% hObject    handle to load_rois (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_2_disk.
function save_2_disk_Callback(hObject, eventdata, handles)
% hObject    handle to save_2_disk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [FileName,PathName] = uiputfile('rois.mat','Save file name');
    rois=handles.rois.CData;
    save([PathName FileName],'rois')

    [FileName,PathName] = uiputfile('rois_fig.mat','Save roi reference image');
    aux = handles.baseimage;
    save([PathName FileName],'aux')

% --- Executes on slider movement.
function frameSlider_Callback(hObject, eventdata, handles)
% hObject    handle to frameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    axes(handles.bigAxes);
    handles.nowFrame=round(handles.frameSlider.Value);
    handles.baseimage=handles.imageStack(:,:,handles.nowFrame);
    handles.frameSlider.Max=size(handles.imageStack,3);
    handles.frameSliderIndicator.String=handles.nowFrame;


    handles.baseimageRGB=handles.baseimage-min(handles.baseimage(:));
    handles.baseimageRGB=handles.baseimageRGB./max(handles.baseimageRGB(:));
    handles.baseimageRGB=repmat(handles.baseimageRGB,[1,1,3]);

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



function smallWinSize_Callback(hObject, eventdata, handles)
% hObject    handle to smallWinSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smallWinSize as text
%        str2double(get(hObject,'String')) returns contents of smallWinSize as a double


% --- Executes during object creation, after setting all properties.
function smallWinSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smallWinSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in method.
function method_Callback(hObject, eventdata, handles)

% hObject    handle to method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function trsh_Callback(hObject, eventdata, handles)
% hObject    handle to trsh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.trsh_val.String=handles.trsh.Value;
mathod_smallWinCenter(hObject,1,handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function trsh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trsh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function trsh_min_Callback(hObject, eventdata, handles)
% hObject    handle to trsh_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.trsh.Min = str2double(handles.trsh_min.String);
% Hints: get(hObject,'String') returns contents of trsh_min as text
%        str2double(get(hObject,'String')) returns contents of trsh_min as a double


% --- Executes during object creation, after setting all properties.
function trsh_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trsh_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function trsh_max_Callback(hObject, eventdata, handles)
% hObject    handle to trsh_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.trsh.Max = str2double(handles.trsh_max.String);
% Hints: get(hObject,'String') returns contents of trsh_max as text
%        str2double(get(hObject,'String')) returns contents of trsh_max as a double


% --- Executes during object creation, after setting all properties.
function trsh_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trsh_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in dilateCell.
function dilateCell_Callback(hObject, eventdata, handles)
% hObject    handle to dilateCell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    mathod_smallWinCenter( hObject , eventdata ,handles);
    guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of dilateCell

% --- Executes on button press in fillCell.
function fillCell_Callback(hObject, eventdata, handles)
% hObject    handle to fillCell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    mathod_smallWinCenter( hObject , eventdata ,handles);
    guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of fillCell


function ImageClickCallback( hObject , eventData ,handles)
    coordinates = get(handles.bigAxes,'CurrentPoint'); %stores last coordinates within the large image
    handles.coor=round([coordinates(1,2),coordinates(1,1)]);
    mathod_smallWinCenter( hObject , eventData ,handles);
    guidata(hObject, handles);


function mathod_smallWinCenter( hObject , eventData ,handles)
if isfield(handles, 'coor')
    
    winSize=cell2mat(textscan(handles.smallWinSize.String,'%f'));
    winInd{1}=handles.coor(1)-round(winSize(1)/2)+1:handles.coor(1)+round(winSize(1)/2);
    winInd{2}=handles.coor(2)-round(winSize(2)/2)+1:handles.coor(2)+round(winSize(2)/2);

    winInd{1}(winInd{1}<0 | winInd{1}>size(handles.baseimage,1))=[];
    winInd{2}(winInd{2}<0 | winInd{2}>size(handles.baseimage,2))=[];


    smallFrame=handles.ref_image.CData(winInd{1},winInd{2},1);
    handles.top_image.CData(1);
    handles.top_image.CData=smallFrame;
    handles.topAxes.XLim=[1 length(winInd{2})];
    handles.topAxes.YLim=[1 length(winInd{1})];


    trsh=handles.trsh.Value;
    option2applay=1;%% increaswe for all option selected

    if handles.dilateCell.Value==1
        options{option2applay}='dilateCell';
        option2applay=option2applay+1;
    else
       options=[];
    end
    
    if handles.fillCell.Value==1
        options{option2applay}='fillCell';
        option2applay=option2applay+1;%%% for future
    end


    [mask]=findCellInFrame(smallFrame,trsh,options);
    mask=mask==1;
    handles.mask=mask;
    smallFrame=smallFrame-min(smallFrame(:));
    smallFrame=smallFrame./max(smallFrame(:));
    smallFrameRgb=repmat(smallFrame,[1,1,3]);
    smallFrameRgb(:,:,1)=mask;%smallFrameRgb(:,:,1)+(((1-smallFrameRgb(:,:,1))*.15).*mask);
    % smallFrameRgb(:,:,2)=smallFrameRgb(:,:,2)-smallFrameRgb(:,:,2).*mask.*.95;
    % smallFrameRgb(:,:,3)=smallFrameRgb(:,:,3)-smallFrameRgb(:,:,3).*mask.*.95;

    handles.low_image.CData=smallFrameRgb;
    handles.topAxes.XLim=[1 length(winInd{2})];
    handles.topAxes.YLim=[1 length(winInd{1})];
    handles.lowAxes.XLim=[1 length(winInd{2})];
    handles.lowAxes.YLim=[1 length(winInd{1})];
    
    set(handles.low_image,'ButtonDownFcn',{@LowImageClickCallback,handles});
    
    guidata(hObject,handles);
end


% --- Executes on button press in exit_button.
function exit_button_Callback(hObject, eventdata, handles)
% hObject    handle to exit_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
closereq


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over trsh.
function trsh_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to trsh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% % --- Executes on mouse press over axes background.
% function LowImageClickCallback(hObject, eventdata, handles)
% % hObject    handle to lowAxes (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% handles = guidata(hObject);
% coordinates = get(handles.lowAxes,'CurrentPoint'); %stores last coordinates within the large image
% coordinates = round([coordinates(1,1),coordinates(1,2)]);
% handles.mask(coordinates(2), coordinates(1)) = ~handles.mask(coordinates(2),coordinates(1)); % toggle pixel
% handles.low_image.CData(:,:,1) = handles.mask;
% guidata(hObject,handles);
