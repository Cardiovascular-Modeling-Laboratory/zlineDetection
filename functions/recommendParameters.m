% RECOMMENDPARAMETERS - Recommend parameters for images of cardiomyocytes

function [ settings ] = recommendParameters()

%%%%%%%%%%%%%%%%%%% Coherence Filter Parameteres %%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the sigma of gaussian smoothing before calculation of the image 
% Hessian.
settings.bio_sigma = 0.08;

% Set the sigma of the Gaussian smoothing of the Hessian.
settings.bio_rho = 0.26; 

% Total Diffusion Time 
settings.diffusion_time = 5; 

%%%%%%%%%%%%%%%%%%%%%% Top Hat Filter Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%

% Radius of the flat disk-shaped structuring element used for the top hat
% filter
settings.bio_tophat_size = 1; 

%%%%%%%%%%%%%%%%%%% Threshold and Clean Pagrameters %%%%%%%%%%%%%%%%%%%%%%%%

% Size of small objects to be removed using bwareopen
settings.bio_noise_area = 0.2; 

%%%%%%%%%%%%%%%%%%%% Skeletonization Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%

% Save the minimum branch size to be included in analysis 
settings.bio_branch_size = 0.6; 

end

