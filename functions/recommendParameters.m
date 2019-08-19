% RECOMMENDPARAMETERS - Recommend parameters for images of cardiomyocytes

function [ settings ] = recommendParameters()
%%%%%%%%%%%%%%%%%%% Actin Filtering Parameteres %%%%%%%%%%%%%%%%%%%%%%%%
settings.grid = 30; 
settings.actin_thresh = 0.7; 

%%%%%%%%%%%%%%%%%%% Coherence Filter Parameteres %%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the sigma of gaussian smoothing before calculation of the image 
% Hessian.
settings.sigma = 1;

% Set the sigma of the Gaussian smoothing of the Hessian.
settings.rho = 1.4; 

% Total Diffusion Time 
settings.diffusion_time = 1.5; 

%%%%%%%%%%%%%%%%%%%%%% Top Hat Filter Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%

% Radius of the flat disk-shaped structuring element used for the top hat
% filter
settings.tophat_size = 3; 

%%%%%%%%%%%%%%%%%%% Background Removal Parameters %%%%%%%%%%%%%%%%%%%%%%%%

% Standard deviation of gaussian smoothing to perform on image 
settings.back_sigma = 1; 

% Size of blocks to break image into 
settings.back_blksze = 15;

% Size of blocks considered "noise" in the condensed image
settings.back_noisesze = 8;

%%%%%%%%%%%%%%%%%%% Threshold and Clean Parameters %%%%%%%%%%%%%%%%%%%%%%%%

% Size of small objects to be removed using bwareopen
settings.noise_area = 2; 

%%%%%%%%%%%%%%%%%%%% Skeletonization Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%

% Save the minimum branch size to be included in analysis 
settings.branch_size = 4; 

end

