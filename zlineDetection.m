function varargout = zlineDetection(varargin)
% ZLINEDETECTION MATLAB code for zlineDetection.fig
%      ZLINEDETECTION, by itself, creates a new ZLINEDETECTION or raises the existing
%      singleton*.
%
%      H = ZLINEDETECTION returns the handle to a new ZLINEDETECTION or the handle to
%      the existing singleton*.
%
%      ZLINEDETECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ZLINEDETECTION.M with the given input arguments.
%
%      ZLINEDETECTION('Property','Value',...) creates a new ZLINEDETECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before zlineDetection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to zlineDetection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help zlineDetection

% Last Modified by GUIDE v2.5 19-Aug-2019 16:25:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @zlineDetection_OpeningFcn, ...
                   'gui_OutputFcn',  @zlineDetection_OutputFcn, ...
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


% --- Executes just before zlineDetection is made visible.
function zlineDetection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to zlineDetection (see VARARGIN)

% Choose default command line output for zlineDetection
handles.output = hObject;

% Add directories that contain code 
addpath('functions');
addpath('functions/coherencefilter_version5b');
addpath('functions/continuous_zline_detection');
addpath('functions/actin_filtering');
addpath('functions/plottingFunctions');


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes zlineDetection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = zlineDetection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function bio_sigma_Callback(hObject, eventdata, handles)
% hObject    handle to sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigma as text
%        str2double(get(hObject,'String')) returns contents of sigma as a double


% --- Executes during object creation, after setting all properties.
function bio_sigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bio_rho_Callback(hObject, eventdata, handles)
% hObject    handle to rho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rho as text
%        str2double(get(hObject,'String')) returns contents of rho as a double


% --- Executes during object creation, after setting all properties.
function bio_rho_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function diffusion_time_Callback(hObject, eventdata, handles)
% hObject    handle to diffusion_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of diffusion_time as text
%        str2double(get(hObject,'String')) returns contents of diffusion_time as a double


% --- Executes during object creation, after setting all properties.
function diffusion_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to diffusion_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bio_noise_area_Callback(hObject, eventdata, handles)
% hObject    handle to bio_noise_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bio_noise_area as text
%        str2double(get(hObject,'String')) returns contents of bio_noise_area as a double


% --- Executes during object creation, after setting all properties.
function bio_noise_area_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bio_noise_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bio_tophat_size_Callback(hObject, eventdata, handles)
% hObject    handle to tophat_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tophat_size as text
%        str2double(get(hObject,'String')) returns contents of tophat_size as a double


% --- Executes during object creation, after setting all properties.
function bio_tophat_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tophat_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pix2um_Callback(hObject, eventdata, handles)
% hObject    handle to pix2um (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pix2um as text
%        str2double(get(hObject,'String')) returns contents of pix2um as a double


% --- Executes during object creation, after setting all properties.
function pix2um_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pix2um (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in disp_df.
function disp_df_Callback(hObject, eventdata, handles)
% hObject    handle to disp_df (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of disp_df


% --- Executes on button press in disp_tophat.
function disp_tophat_Callback(hObject, eventdata, handles)
% hObject    handle to disp_tophat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of disp_tophat


% --- Executes on button press in disp_nonoise.
function disp_nonoise_Callback(hObject, eventdata, handles)
% hObject    handle to disp_nonoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of disp_nonoise


% --- Executes on button press in disp_back.
function disp_back_Callback(hObject, eventdata, handles)
% hObject    handle to disp_back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of disp_back


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


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



function gloabl_thresh_Callback(hObject, eventdata, handles)
% hObject    handle to gloabl_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gloabl_thresh as text
%        str2double(get(hObject,'String')) returns contents of gloabl_thresh as a double


% --- Executes during object creation, after setting all properties.
function gloabl_thresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gloabl_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bio_branch_size_Callback(hObject, eventdata, handles)
% hObject    handle to branch_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of branch_size as text
%        str2double(get(hObject,'String')) returns contents of branch_size as a double


% --- Executes during object creation, after setting all properties.
function bio_branch_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to branch_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RUN.
function RUN_Callback(hObject, eventdata, handles)
% hObject    handle to RUN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

RUNzlineDetection(handles); 
% % Logical whether user wants to load old image paths 
% loadImagePaths = get(handles.loadImagePaths, 'Value'); 
% % Logical whether user wants to load old settings
% loadSettings = get(handles.loadSettings, 'Value'); 
% 
% % Store all of the inputs from the GUI in the structural array called
% % settings 
% if ~loadSettings
%     settings = getGUIsettings(handles);     
% end 
% 
% 
% 
% %Once completed... 
% runMultipleCoverSlips(settings); 

% --- Executes on button press in tf_OOP.
function tf_OOP_Callback(hObject, eventdata, handles)
% hObject    handle to tf_OOP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tf_OOP

function dp_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to dp_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dp_threshold as text
%        str2double(get(hObject,'String')) returns contents of dp_threshold as a double

% --- Executes during object creation, after setting all properties.
function dp_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dp_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in tf_CZL.
function tf_CZL_Callback(hObject, eventdata, handles)
% hObject    handle to tf_CZL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tf_CZL


% --- Executes on button press in rec_params.
function rec_params_Callback(hObject, eventdata, handles)
% hObject    handle to rec_params (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check with the user that they would like to over write the settings
doRecParams = questdlg('Recommend Settings will overwrite any analysis settings and parameters you have already set. Do you want zlineDetection to Recommend Settings?', ...
        'Recommend Settings Overwrite Warning','Yes','No','Yes');

% Only recommend parameters if the user would like.
if strcmp('Yes',doRecParams)
    % If the user would like parameters, this function stores the
    % recommendations 
    settings = recommendParameters(); 

    % Set all of the parameters 
    %>> Coherence Filter Parameters
    set( handles.sigma, 'String', num2str( settings.sigma ) );
    set( handles.rho, 'String', num2str( settings.rho ) ); 
    %>> Coherence Filter Parameters
    set( handles.diffusion_time, 'String', ...
        num2str( settings.diffusion_time ) ); 
    %>> Top Hat Filter Parameters
    set( handles.tophat_size, 'String', ...
        num2str( settings.tophat_size ) );
    %>> Background Removal Parameters
    set( handles.back_sigma, 'String', ...
        num2str( settings.back_sigma ) ); 
    set( handles.back_blksze, 'String', ...
        num2str( settings.back_blksze ) ); 
    set( handles.back_noisesze, 'String', ...
        num2str( settings.back_noisesze ) ); 
    %>> Threshold and Clean Parameters
    set( handles.noise_area, 'String', ...
        num2str( settings.noise_area ) ); 
    %>> Skeletonization Parameters
    set( handles.branch_size, 'String', ...
        num2str( settings.branch_size ) );
    %>> Set actin filtering to be true
    set(handles.actin_filt,'Value',1);
    %>> Actin filtering parameters
    set( handles.grid, 'String', ...
        num2str( settings.grid ) );
    set( handles.actin_thresh, 'String', ...
        num2str( settings.actin_thresh ) );
    %>> Continuous z-line detection 
    set(handles.tf_CZL, 'Value',1); 
    %>> Continuous z-line detection 
    set(handles.tf_OOP, 'Value',1); 
    guidata(hObject, handles);
end
                


% --- Executes on selection change in cardio_type.
function cardio_type_Callback(hObject, eventdata, handles)
% hObject    handle to cardio_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cardio_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cardio_type


% --- Executes during object creation, after setting all properties.
function cardio_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cardio_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in disp_skel.
function disp_skel_Callback(hObject, eventdata, handles)
% hObject    handle to disp_skel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of disp_skel



function sigma_Callback(hObject, eventdata, handles)
% hObject    handle to sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigma as text
%        str2double(get(hObject,'String')) returns contents of sigma as a double

% --- Executes during object creation, after setting all properties.
function sigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');

end



function rho_Callback(hObject, eventdata, handles)
% hObject    handle to rho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rho as text
%        str2double(get(hObject,'String')) returns contents of rho as a double


% --- Executes during object creation, after setting all properties.
function rho_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tophat_size_Callback(hObject, eventdata, handles)
% hObject    handle to tophat_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tophat_size as text
%        str2double(get(hObject,'String')) returns contents of tophat_size as a double


% --- Executes during object creation, after setting all properties.
function tophat_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tophat_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function noise_area_Callback(hObject, eventdata, handles)
% hObject    handle to noise_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noise_area as text
%        str2double(get(hObject,'String')) returns contents of noise_area as a double


% --- Executes during object creation, after setting all properties.
function noise_area_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noise_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function branch_size_Callback(hObject, eventdata, handles)
% hObject    handle to branch_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of branch_size as text
%        str2double(get(hObject,'String')) returns contents of branch_size as a double


% --- Executes during object creation, after setting all properties.
function branch_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to branch_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in convert_params.
function convert_params_Callback(hObject, eventdata, handles)
% hObject    handle to convert_params (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Convert parameters from microns to pixels
[ settings ] = convertParameters( handles );

% Set all of the parameters 
%>> Coherence Filter Parameters
set( handles.sigma, 'String', num2str( settings.sigma ) );
set( handles.rho, 'String', num2str( settings.rho ) ); 
%>> Top Hat Filter Parameters
set( handles.tophat_size, 'String', num2str( settings.tophat_size ) );   
%>> Skeletonization Parameters
set( handles.branch_size, 'String', num2str( settings.branch_size ) ); 



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



function grid2_Callback(hObject, eventdata, handles)
% hObject    handle to grid2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of grid2 as text
%        str2double(get(hObject,'String')) returns contents of grid2 as a double


% --- Executes during object creation, after setting all properties.
function grid2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to grid2 (see GCBO)
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


% --- Executes on button press in disp_actin.
function disp_actin_Callback(hObject, eventdata, handles)
% hObject    handle to disp_actin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of disp_actin


% --- Executes on button press in actin_filt.
function actin_filt_Callback(hObject, eventdata, handles)
% hObject    handle to actin_filt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of actin_filt



function back_blksze_Callback(hObject, eventdata, handles)
% hObject    handle to back_blksze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of back_blksze as text
%        str2double(get(hObject,'String')) returns contents of back_blksze as a double


% --- Executes during object creation, after setting all properties.
function back_blksze_CreateFcn(hObject, eventdata, handles)
% hObject    handle to back_blksze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function num_cs_Callback(hObject, eventdata, handles)
% hObject    handle to num_cs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_cs as text
%        str2double(get(hObject,'String')) returns contents of num_cs as a double


% --- Executes during object creation, after setting all properties.
function num_cs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_cs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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


% --- Executes on button press in multi_cond.
function multi_cond_Callback(hObject, eventdata, handles)
% hObject    handle to multi_cond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of multi_cond


% --- Executes on button press in diffusion_explore.
function diffusion_explore_Callback(hObject, eventdata, handles)
% hObject    handle to diffusion_explore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of diffusion_explore


% --- Executes on button press in rm_background.
function rm_background_Callback(hObject, eventdata, handles)
% hObject    handle to rm_background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rm_background



function back_noisesze_Callback(hObject, eventdata, handles)
% hObject    handle to back_noisesze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of back_noisesze as text
%        str2double(get(hObject,'String')) returns contents of back_noisesze as a double


% --- Executes during object creation, after setting all properties.
function back_noisesze_CreateFcn(hObject, eventdata, handles)
% hObject    handle to back_noisesze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function back_sigma_Callback(hObject, eventdata, handles)
% hObject    handle to back_sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of back_sigma as text
%        str2double(get(hObject,'String')) returns contents of back_sigma as a double


% --- Executes during object creation, after setting all properties.
function back_sigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to back_sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadOLD.
function loadOLD_Callback(hObject, eventdata, handles)
% hObject    handle to loadOLD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in loadSettings.
function loadSettings_Callback(hObject, eventdata, handles)
% hObject    handle to loadSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc
loadImagePaths = get(handles.loadImagePaths, 'Value'); 
if ~loadImagePaths
    disp('You will be asked to load a .mat file with previous parameter settings.'); 
    disp('Push "RUN" to proceed and select image paths.'); 
else
    disp('You will be asked to load a .mat file with previous image paths and settings. Push "Run" to proceed.'); 
end % Hint: get(hObject,'Value') returns toggle state of loadSettings


% --- Executes on button press in loadImagePaths.
function loadImagePaths_Callback(hObject, eventdata, handles)
% hObject    handle to loadImagePaths (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc
loadSettings = get(handles.loadSettings, 'Value'); 
if ~loadSettings
    disp('You will be asked to load a .mat file with previous image paths.'); 
    disp('After setting the parameters, Push "RUN" to proceed.'); 
else
    disp('You will be asked to load a .mat file with previous image paths and settings. Push "Run" to proceed.'); 
end 

% Hint: get(hObject,'Value') returns toggle state of loadImagePaths
