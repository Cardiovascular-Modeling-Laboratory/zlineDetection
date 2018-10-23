
% Add subdirectories to path 
addpath('functions/coherencefilter_version5b');
addpath('functions/continuous_zline_detection');

% Variable parameters 
%settings.orientsmoothsigma - gaussian smoothing before calculation of the 
%image Hessian
var_sigma = 0.25:0.25:1; 
%Sigma of the Gaussian smoothing of the Hessian.
var_rho = 0.5:0.25:4;
% Total Diffusion Time 
var_diffusiontime = [1,3,5,8,10,12,15,20,25,50,100,200]; 

%%%%%%%%%%%%%%%%%%%%% Set nonvariable parameters %%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize structural arrays. 
settings = struct(); 
Options = struct();

% Pixel to micron conversion
settings.pix2um = 6.22; 
% Radius of the flat disk-shaped structuring element used for the top hat
% filter
settings.bio_tophat_size = 0.5; 
settings.tophat_size = round( settings.bio_tophat_size.*pix2um ); 
% Size of small objects to be removed using bwareopen
settings.bio_noise_area = 0.2;
settings.noise_area= round( settings.bio_noise_area.*(pix2um.^2) ); 
% Save the minimum branch size to be included in analysis 
settings.bio_branch_size = 0.6; 
settings.branch_size = round( settings.bio_branch_size.*pix2um ); 

% Display figures
settings.disp_df = false; 
settings.disp_tophat = false; 
settings.disp_bw = false;
settings.disp_nonoise = false; 
settings.disp_skel = false;

% Calculate continuous z-line length 
settings.tf_CZL = true; 
settings.dp_threshold = 0.99; 

% Calculate OOP
settings.tf_OOP = false; 
settings.cardio_type = true; 

% PRESET VALUE. Set the diffusion time stepsize 
Options.dt = 0.15;

% PRESET VALUE. Set the numerical diffusion scheme that the program should 
% use. This will be set to 'I', Implicit Discretization (only works in 2D)
Options.Scheme = 'I';

% PRESET VALUE. Use Weickerts equation (plane like kernel) to make the 
% diffusion tensor. 
Options.eigenmode = 0;

% PRESET VALUE. Constant that determines the amplitude of the diffusion  in 
% smoothing Weickert equation
Options.C = 1E-10;

% Save the Options in the settings struct. 
settings.Options = Options;
 
%%%%%%%%%%%%%%%%%%%%% Set nonvariable parameters %%%%%%%%%%%%%%%%%%%%%%%%%%


% Options for diffusion filtering 
%settings.Options.sigma, settings.Options.rho, settings.Options.T, 
% % Convert the sigma of gaussian smoothing before calculation of the image 
% % Hessian.
% settings.sigma = settings.bio_sigma.*pix2um; 
% 
% % Convert the sigma of the Gaussian smoothing of the Hessian.
% settings.rho = settings.bio_rho.*pix2um;
% 
 %settings.bio_sigma, settings.bio_rho, 

%%%%%%%%%%%%%%%%%%%%% Set nonvariable parameters %%%%%%%%%%%%%%%%%%%%%%%%%%

s_string = num2str(Options.sigma); 
s_string = strrep(s_string, '.', 'p'); 
D8_sigma0p5_rho1

