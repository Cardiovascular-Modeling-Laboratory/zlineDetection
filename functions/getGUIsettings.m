% GETGUISETTINGS - store all of the settings in a structural array. 
%
% This function will collect all of the options selected by the user and
% output them in a structural array
%
%
% Usage:
%  settings = getGUIsettings(handles); 
%
% Arguments:
%       handles     - 
% Returns:
%       settings    - structural array that contains the following
%                       parameters from the GUI:
%           
% 
% Suggested parameters: 
% 
% See also: 

function settings = getGUIsettings(handles)

%%%%%%%%%%%%%%%%%%%%%%% Physical Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Save the pixel to micron conversion 
settings.pix2um = str2double(get(handles.pix2um,'String'));


%%%%%%%%%%%%%%%%%%% Coherence Filter Parameteres %%%%%%%%%%%%%%%%%%%%%%%%%%
% Build the Coherence Filter structure array called Options. This will be
% used by "coherencefilter_version5b" Copyright (c) 2009, Dirk-Jan Kroon

% Create structures array to store the settings values 
Options = struct();

% Set the sigma of gaussian smoothing before calculation of the image 
% Hessian. The user input a value in microns, which should be converted
% into pixels before using
% Store biological user input 
bio_sigma = str2double(get(handles.guass_sigma,'String'));
% Convert user input into pixels and then save in the structure array
Options.sigma = bio_sigma.*pix2um; 

% Rho gives the sigma of the Gaussian smoothing of the Hessian.
% Store biological user input 
bio_rho = str2double(get(handles.orient_sigma,'String'));
% Convert user input into pixels and then save in the structure array
Options.rho = bio_rho.*pix2um;

% Get the total diffusion time from the GUI
Options.T = str2double(get(handles.diffusion_time,'String'));

% Set the diffusion time stepsize (preset value) 
Options.dt = 0.15;

% Set the numerical diffusion scheme that the program should use. This will
% be set to 'I', Implicit Discretization (only works in 2D)
Options.Scheme = 'I';

% Use Weickerts equation (plane like kernel) to make the diffusion tensor. 
Options.eigenmode = 0;

% Constant that determines the amplitude of the diffusion smoothing in 
% Weickert equation
Options.C = 1E-10;

% Save the Options in the settings struct. 
settings.Options = Options;

%%%%%%%%%%%%%%%%%%%%%% Top Hat Filter Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%

% Store biological user input 
bio_th = str2double(get(handles.tophat_size,'String'));
% Convert user input into pixels and then save in the structure array
settings.thpix = bio_th.*pix2um; 

%%%%%%%%%%%%%%%%%%%%%% Haven't been modified %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 
% 
% settings.thnm = str2num(get(handles.tophatSize,'String'));
% settings.noisenm = str2num(get(handles.noiseArea,'String'));
% settings.maxBranchSizenm = str2num(get(handles.maxBranchSize,'String'));
% 
% % settings.maxStubLennm = str2num(get(handles.maxStubLen,'String'));
% settings.globalThresh = str2num(get(handles.globalThresh,'String'));
% 
% % Get figure display settings
% settings.CEDFig = get(handles.CEDFig,'Value');
% settings.topHatFig = get(handles.topHatFig,'Value');
% settings.threshFig = get(handles.threshFig,'Value');
% settings.noiseRemFig = get(handles.noiseRemFig,'Value');
% settings.skelFig = get(handles.skelFig,'Value');
% settings.skelTrimFig = get(handles.skelTrimFig,'Value');
% settings.threshMethod = get(handles.threshMethod,'Value');
% 
% settings.figSave = get(handles.saveFigs,'Value');

% % Build the Coherence Filter options structure - need to annotate 
% Options = struct();
% Options.Scheme = 'I';
% settings.gaussnm = str2num(get(handles.gauss,'String'));
% settings.rhonm = str2num(get(handles.rho,'String'));
% % Options.sigma = gausspix;
% % Options.rho = rhopix;
% Options.T = str2num(get(handles.difftime,'String'));
% Options.dt = 0.15;
% % Options.eigenmode = 5;
% Options.eigenmode = 0;
% Options.C = 1E-10;
% 
% settings.Options = Options;
end