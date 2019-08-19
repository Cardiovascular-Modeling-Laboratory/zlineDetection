function [varargout] = actinSegmentationParameters(varargin)
% ACTINSEGMENTATIONPARAMETERS MATLAB code for actinSegmentationParameters.fig
%      ACTINSEGMENTATIONPARAMETERS, by itself, creates a new ACTINSEGMENTATIONPARAMETERS or raises the existing
%      singleton*.
%
%      H = ACTINSEGMENTATIONPARAMETERS returns the handle to a new ACTINSEGMENTATIONPARAMETERS or the handle to
%      the existing singleton*.
%
%      ACTINSEGMENTATIONPARAMETERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ACTINSEGMENTATIONPARAMETERS.M with the given input arguments.
%
%      ACTINSEGMENTATIONPARAMETERS('Property','Value',...) creates a new ACTINSEGMENTATIONPARAMETERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before actinSegmentationParameters_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to actinSegmentationParameters_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help actinSegmentationParameters

% Last Modified by GUIDE v2.5 19-Aug-2019 14:17:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @actinSegmentationParameters_OpeningFcn, ...
                   'gui_OutputFcn',  @actinSegmentationParameters_OutputFcn, ...
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


% --- Executes just before actinSegmentationParameters is made visible.
function actinSegmentationParameters_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to actinSegmentationParameters (see VARARGIN)

% Choose default command line output for actinSegmentationParameters
handles.output = hObject;
actin_settings = struct(); 
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes actinSegmentationParameters wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = actinSegmentationParameters_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in grid_explore.
function grid_explore_Callback(hObject, eventdata, handles)
% hObject    handle to grid_explore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of grid_explore


% --- Executes on button press in actinthresh_explore.
function actinthresh_explore_Callback(hObject, eventdata, handles)
% hObject    handle to actinthresh_explore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of actinthresh_explore



function actin_sigma_Callback(hObject, eventdata, handles)
% hObject    handle to actin_sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of actin_sigma as text
%        str2double(get(hObject,'String')) returns contents of actin_sigma as a double


% --- Executes during object creation, after setting all properties.
function actin_sigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to actin_sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function actin_kernelsize_Callback(hObject, eventdata, handles)
% hObject    handle to actin_kernelsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of actin_kernelsize as text
%        str2double(get(hObject,'String')) returns contents of actin_kernelsize as a double


% --- Executes during object creation, after setting all properties.
function actin_kernelsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to actin_kernelsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function actin_backthresh_Callback(hObject, eventdata, handles)
% hObject    handle to actin_backthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of actin_backthresh as text
%        str2double(get(hObject,'String')) returns contents of actin_backthresh as a double


% --- Executes during object creation, after setting all properties.
function actin_backthresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to actin_backthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function actin_reliablethresh_Callback(hObject, eventdata, handles)
% hObject    handle to actin_reliablethresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of actin_reliablethresh as text
%        str2double(get(hObject,'String')) returns contents of actin_reliablethresh as a double


% --- Executes during object creation, after setting all properties.
function actin_reliablethresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to actin_reliablethresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function grid_Callback(hObject, eventdata, handles)
% hObject    handle to grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of grid as text
%        str2double(get(hObject,'String')) returns contents of grid as a double


% --- Executes during object creation, after setting all properties.
function grid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function actin_thresh_Callback(hObject, eventdata, handles)
% hObject    handle to actin_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of actin_thresh as text
%        str2double(get(hObject,'String')) returns contents of actin_thresh as a double


% --- Executes during object creation, after setting all properties.
function actin_thresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to actin_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function actin_gradientsigma_Callback(hObject, eventdata, handles)
% hObject    handle to actin_gradientsigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of actin_gradientsigma as text
%        str2double(get(hObject,'String')) returns contents of actin_gradientsigma as a double


% --- Executes during object creation, after setting all properties.
function actin_gradientsigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to actin_gradientsigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function actin_blocksigma_Callback(hObject, eventdata, handles)
% hObject    handle to actin_blocksigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of actin_blocksigma as text
%        str2double(get(hObject,'String')) returns contents of actin_blocksigma as a double


% --- Executes during object creation, after setting all properties.
function actin_blocksigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to actin_blocksigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function actin_orientsmoothsigma_Callback(hObject, eventdata, handles)
% hObject    handle to actin_orientsmoothsigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of actin_orientsmoothsigma as text
%        str2double(get(hObject,'String')) returns contents of actin_orientsmoothsigma as a double


% --- Executes during object creation, after setting all properties.
function actin_orientsmoothsigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to actin_orientsmoothsigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GET_actinparams.
function GET_actinparams_Callback(hObject, eventdata, handles)
% hObject    handle to GET_actinparams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Create a struct for the actin segmentation parameters
actin_settings = struct(); 

% ACTIN SEGMENTATION: Save the grid sizes for the rows and columns in an array 
grid_size(1) = round( str2double(get(handles.grid, 'String')) );
grid_size(2) = round( str2double(get(handles.grid, 'String')) );

% ACTIN SEGMENTATION: Store the grid sizes
actin_settings.grid_size = grid_size; 

% ACTIN SEGMENTATION: Store the threshold for actin filtering
actin_settings.actin_thresh = str2double(get(handles.actin_thresh, 'String')); 

% ACTIN SEGMENTATION: Store settings for actin threshold exploration 
actin_settings.grid_explore = get(handles.grid_explore, 'Value'); 
% ACTIN SEGMENTATION: Store settings for actin grid size exploration 
actin_settings.actinthresh_explore = get(handles.actinthresh_explore, 'Value'); 

% ACTIN DETECTION: Sigma of gaussian filter 
actin_settings.actin_sigma = str2double(get(handles.actin_sigma, 'String')); 
% ACTIN DETECTION: Kernel size of gaussian filter
actin_settings.actin_kernelsize = ...
    str2double(get(handles.actin_kernelsize, 'String')); 

% ACTIN DETECTION: Segmentation threshold
actin_settings.actin_backthresh = ...
    str2double(get(handles.actin_backthresh, 'String')); 

% ACTIN DETECTION: Reliability threshold 
actin_settings.actin_reliablethresh = ...
    str2double(get(handles.actin_reliablethresh, 'String')); 

% ACTIN DETECTION: Sigma of the derivative of Gaussian used to compute image gradients.
actin_settings.actin_gradientsigma = ...
    str2double(get(handles.actin_gradientsigma, 'String')); 
% ACTIN DETECTION: Sigma of the Gaussian weighting used to sum the gradient moments.
actin_settings.actin_blocksigma = ...
    str2double(get(handles.actin_blocksigma, 'String')); 
% ACTIN DETECTION: Sigma of the Gaussian used to smooth the final orientation vector field.
actin_settings.actin_orientsmoothsigma = ...
    str2double(get(handles.actin_orientsmoothsigma, 'String')); 
    
