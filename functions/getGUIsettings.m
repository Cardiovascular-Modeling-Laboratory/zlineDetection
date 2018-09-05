% GETGUISETTINGS - store all of the settings in a structural array. 
%
% This function
%
%
% Usage:
%  Vf = YBiter(V0); 
%
% Arguments:
%       V0          - 
% Returns:
%       Vf          - 
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
bio_sigma = str2double(get(handles.gauss,'String'));

Options.sigma = bio_sigma / pix2um; 

% Rho gives the sigma of the Gaussian smoothing of the Hessian.
settings.rhonm = str2double(get(handles.rho,'String'));
Options.rho = 1; 

% Get the total diffusion time from the GUI
Options.T = str2double(get(handles.difftime,'String'));

% Set the diffusion time stepsize
Options.dt = 0.15;

%   Options.verbose : Show information about the filtering, values :
%                     'none', 'iter' (default) , 'full'

%   Options.eigenmode : There are many different equations to make an diffusion tensor,
%						this value (only 3D) selects one.
%					    0 (default) : Weickerts equation, line like kernel
%						1 : Weickerts equation, plane like kernel
%						2 : Edge enhancing diffusion (EED)
%						3 : Coherence-enhancing diffusion (CED)
%						4 : Hybrid Diffusion With Continuous Switch (HDCS)

% Set the numerical diffusion scheme that the program should use. This will
% be set to 'I', Implicit Discretization (only works in 2D)
Options.Scheme = 'I';


%   Options.eigenmode : There are many different equations to make an diffusion tensor,
%						this value (only 3D) selects one.
%					    0 (default) : Weickerts equation, line like kernel
%						1 : Weickerts equation, plane like kernel
%						2 : Edge enhancing diffusion (EED)
%						3 : Coherence-enhancing diffusion (CED)
%						4 : Hybrid Diffusion With Continuous Switch (HDCS)

% Options.eigenmode = 5;
Options.eigenmode = 0;
% Constants which determine the amplitude of the diffusion smoothing in 
% Weickert equation
%   Options.C :     Default 1e-10

Options.C = 1E-10;

% Save the Options in the settings struct. 
settings.Options = Options;

%%%%%%%%%%%%%%%%%%%%%% Haven't been modified %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



settings.thnm = str2num(get(handles.tophatSize,'String'));
settings.noisenm = str2num(get(handles.noiseArea,'String'));
settings.maxBranchSizenm = str2num(get(handles.maxBranchSize,'String'));

% settings.maxStubLennm = str2num(get(handles.maxStubLen,'String'));
settings.globalThresh = str2num(get(handles.globalThresh,'String'));

% Get figure display settings
settings.CEDFig = get(handles.CEDFig,'Value');
settings.topHatFig = get(handles.topHatFig,'Value');
settings.threshFig = get(handles.threshFig,'Value');
settings.noiseRemFig = get(handles.noiseRemFig,'Value');
settings.skelFig = get(handles.skelFig,'Value');
settings.skelTrimFig = get(handles.skelTrimFig,'Value');
settings.threshMethod = get(handles.threshMethod,'Value');

settings.figSave = get(handles.saveFigs,'Value');

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