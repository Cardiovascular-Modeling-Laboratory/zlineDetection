% RECOMMENDPARAMETERS - Recommend parameters for images of cardiomyocytes

function [ settings ] = recommendParameters()
%%%%%%%%%%%%%%%%%%% Actin Filtering Parameteres %%%%%%%%%%%%%%%%%%%%%%%%
settings.grid1 = 30; 
settings.grid2 = 30; 
settings.actin_thresh = 0.7; 

%%%%%%%%%%%%%%%%%%% Coherence Filter Parameteres %%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the sigma of gaussian smoothing before calculation of the image 
% Hessian.
settings.bio_sigma = 0.1608;

% Set the sigma of the Gaussian smoothing of the Hessian.
settings.bio_rho = 0.2251; 

% Total Diffusion Time 
settings.diffusion_time = 1.5; 

%%%%%%%%%%%%%%%%%%%%%% Top Hat Filter Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%

% Radius of the flat disk-shaped structuring element used for the top hat
% filter
settings.bio_tophat_size = 0.5; 

%%%%%%%%%%%%%%%%%%% Background Removal Parameters %%%%%%%%%%%%%%%%%%%%%%%%

% Standard deviation of gaussian smoothing to perform on image 
settings.back_sigma = 1; 

% Size of blocks to break image into 
settings.back_blksze = 15;

% Size of blocks considered "noise" in the condensed image
settings.back_noisesze = 8;

%%%%%%%%%%%%%%%%%%% Threshold and Clean Parameters %%%%%%%%%%%%%%%%%%%%%%%%

% Size of small objects to be removed using bwareopen
settings.bio_noise_area = 0; 

%%%%%%%%%%%%%%%%%%%% Skeletonization Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%

% Save the minimum branch size to be included in analysis 
settings.bio_branch_size = 0.6; 

end

