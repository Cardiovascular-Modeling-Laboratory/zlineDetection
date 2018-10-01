% RECOMMENDPARAMETERS - Recommend parameters for images of cardiomyocytes

function [ settings ] = recommendParameters( handles )

% Store the pixel to micron conversion 
pix2um = str2double(get(handles.pix2um,'String'));

%%%%%%%%%%%%%%%%%%% Coherence Filter Parameteres %%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the sigma of gaussian smoothing before calculation of the image 
% Hessian.
settings.bio_sigma = 3.37124;
settings.sigma = settings.bio_sigma./pix2um; 

% Set the sigma of the Gaussian smoothing of the Hessian.
settings.bio_rho = 10.11372; 
settings.rho = settings.bio_rho./pix2um;

% Total Diffusion Time 
settings.diffusion_time = 5; 

%%%%%%%%%%%%%%%%%%%%%% Top Hat Filter Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%

% Radius of the flat disk-shaped structuring element used for the top hat
% filter
settings.bio_tophat_size = 10.11372; 
settings.tophat_size = round( settings.bio_tophat_size./pix2um ); 

%%%%%%%%%%%%%%%%%%% Threshold and Clean Parameters %%%%%%%%%%%%%%%%%%%%%%%%

% Size of small objects to be removed using bwareopen
settings.bio_noise_area = 170.478887064; 
settings.noise_area= round( settings.bio_noise_area./(pix2um.^2) ); 

%%%%%%%%%%%%%%%%%%%% Skeletonization Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%

% Save the minimum branch size to be included in analysis 
settings.bio_branch_size = 26.96992; 
settings.branch_size = round( settings.bio_branch_size./pix2um ); 

end

