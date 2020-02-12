% RECOMMENDPARAMETERS - Recommend parameters for images of cardiomyocytes

function [ settings ] = recommendParameters( pix2um )
% The parameters were optimized for the pixel to micron ratio of 6.22 
% Recommend parameters based on this optimized value 
opt_pix2um = 6.22; 
factor = pix2um/opt_pix2um; 

%%%%%%%%%%%%%%%%%%% Actin Filtering Parameteres %%%%%%%%%%%%%%%%%%%%%%%%
settings.grid = round(30*factor); 
settings.actin_thresh = 0.7; 

%%%%%%%%%%%%%%%%%%% Coherence Filter Parameteres %%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the sigma of gaussian smoothing before calculation of the image 
% Hessian.
settings.sigma = round(1*factor,2);

% Set the sigma of the Gaussian smoothing of the Hessian.
settings.rho = round(1.4*factor); 

% Total Diffusion Time 
settings.diffusion_time = 1.5; 

%%%%%%%%%%%%%%%%%%%%%% Top Hat Filter Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%

% Radius of the flat disk-shaped structuring element used for the top hat
% filter
settings.tophat_size = round(3*factor); 

%%%%%%%%%%%%%%%%%%% Background Removal Parameters %%%%%%%%%%%%%%%%%%%%%%%%

% Standard deviation of gaussian smoothing to perform on image 
settings.back_sigma = round(1*factor,2); 

% Size of blocks to break image into 
settings.back_blksze = round(15*factor);

% Size of blocks considered "noise" in the condensed image
settings.back_noisesze = round(8*factor);

%%%%%%%%%%%%%%%%%%% Threshold and Clean Parameters %%%%%%%%%%%%%%%%%%%%%%%%

% Size of small objects to be removed using bwareopen
settings.noise_area = round(2*factor); 

%%%%%%%%%%%%%%%%%%%% Skeletonization Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%

% Save the minimum branch size to be included in analysis 
settings.branch_size = round(4*factor); 

end

