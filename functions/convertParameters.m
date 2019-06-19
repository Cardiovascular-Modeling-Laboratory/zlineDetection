% convertParameters - For usage with zlineDetection.m ONLY. Convert 
% parameters from microns to pixels 
%
% Usage: 
%   settings = convertParameters( handles )
%
% Arguments:
%   handles     - an object that indirectly references its data, which is 
%                   zlineDetection parameters from the GUI 
%                   Class Support: OBJECT 
% Returns:
%   settings    - zlineDetection parameters converted into pixels 
%                   Class Support: STRUCT
%
% Dependencies: 
%   MATLAB Version >= 9.5 
%   Functions: 
%       additionalUserInput.m
%       getGUIsettings.m
%
% Tessa Morris
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [ settings ] = convertParameters( handles )

% Get all of the GUIsettings 
settings = getGUIsettings(handles, true);

% Store the pixel to micron conversion 
pix2um = str2double(get(handles.pix2um,'String'));

%%%%%%%%%%%%%%%%%%% Coherence Filter Parameteres %%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert the sigma of gaussian smoothing before calculation of the image 
% Hessian.
settings.sigma = settings.bio_sigma.*pix2um; 

% Convert the sigma of the Gaussian smoothing of the Hessian.
settings.rho = settings.bio_rho.*pix2um;

%%%%%%%%%%%%%%%%%%%%%% Top Hat Filter Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%

% Radius of the flat disk-shaped structuring element used for the top hat
% filter
settings.tophat_size = round( settings.bio_tophat_size.*pix2um ); 

%%%%%%%%%%%%%%%%%%% Threshold and Clean Parameters %%%%%%%%%%%%%%%%%%%%%%%%

% Size of small objects to be removed using bwareopen
settings.noise_area= round( settings.bio_noise_area.*(pix2um.^2) ); 

%%%%%%%%%%%%%%%%%%%% Skeletonization Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%

% Save the minimum branch size to be included in analysis 
settings.branch_size = round( settings.bio_branch_size.*pix2um ); 

end

