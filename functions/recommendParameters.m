% RECOMMENDPARAMETERS - Recommend parameters for images of cardiomyocytes

function [ settings ] = recommendParameters()

%%%%%%%%%%%%%%%%%%% Coherence Filter Parameteres %%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the sigma of gaussian smoothing before calculation of the image 
% Hessian.
settings.bio_sigma = 0.1608;

% Set the sigma of the Gaussian smoothing of the Hessian.
settings.bio_rho = 0.4823; 

% Total Diffusion Time 
settings.diffusion_time = 8; 

%%%%%%%%%%%%%%%%%%%%%% Top Hat Filter Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%

% Radius of the flat disk-shaped structuring element used for the top hat
% filter
settings.bio_tophat_size = 0.5; 

%%%%%%%%%%%%%%%%%%% Threshold and Clean Parameters %%%%%%%%%%%%%%%%%%%%%%%%

% Size of small objects to be removed using bwareopen
settings.bio_noise_area = 0.2; 

% Remove non-reliable orientations from the orientation matrix based on the
% actin orientation
settings.reliability_thresh = 0.5;

%%%%%%%%%%%%%%%%%%%% Skeletonization Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%

% Save the minimum branch size to be included in analysis 
settings.bio_branch_size = 0.6; 

end

