% This function is a collection of test cases for continuous z-line
% detection 
% It will create test cases and the ground truth distance to be compare
% against z-line detection.

%% Initialization 
num_cases = 8; 
% Store the binary image 
syn_positions = cell(num_cases,1); 

% Store orientation angles 
syn_angles = cell(num_cases,1); 

% Initalize true distancecs 
true_distances = zeros(num_cases,1); 

% Initalize text description
description_txt = cell(num_cases,1); 

%% Synthetic Case 1: 
% Set the case
sc = 1;
% 5 vertical pixels all exactly 90 degrees with no variability
description_txt{sc,1} = ...
    'vertical pixels, no positional variability, no angle variability';

% Set the synthetic image to be 7x7 pixels
sze = 7; 
positions = zeros(sze,sze); 
bnds = 1; 
mid = sze/2 + 0.5; 

% Create positions 
positions((1+bnds):(sze-bnds), round(mid)) = 1; 

% Create the orientation angles 
orientim = (pi/2)*positions; 

% Calculate and store the true distance
true_distances(sc,1) = sqrt( (mid - mid)^2 + ((1+bnds)-(sze-bnds))^2 ); 

% Store the binary image 
syn_positions{sc,1} = positions; 

% Store orientation angles 
syn_angles{sc,1} = orientim;  

clear positions orientim 

%% Synthetic 2
% Set the case
sc = sc + 1; 

% 5 horizontal pixels all exactly 180 degrees with no variability
description_txt{sc,1} = ...
    'horizontal pixels, no positional variability, no angle variability';

% Set the synthetic image to be 7x7 pixels
sze = 7; 
positions = zeros(sze,sze); 
bnds = 1; 
mid = sze/2 + 0.5; 

% Create positions 
positions(round(mid),(1+bnds):(sze-bnds)) = 1; 

% Create the orientation angles 
orientim = (pi)*positions; 

% Calculate and store the true distance
true_distances(sc,1) = sqrt( (mid - mid)^2 + ((1+bnds)-(sze-bnds))^2 ); 

% Store the binary image 
syn_positions{sc,1} = positions; 

% Store orientation angles 
syn_angles{sc,1} = orientim;  

clear positions orientim 

%% Synthetic 3
% Set the case
sc = sc + 1; 

% 5 horizontal pixels all exactly 180 degrees with variability in positions
description_txt{sc,1} = ...
    'horizontal pixels, positional variability, no angle variability';

% Set the synthetic image to be 7x7 pixels
sze = 7; 
positions = zeros(sze,sze); 
bnds = 1; 
mid = sze/2 + 0.5; 

% Create positions 
vals = (1+bnds):(sze-bnds); 
for k = 1:length(vals)
    if mod(k,2) == 0
        nn = 0;
    else
        nn = 1; 
    end 
    positions(round(mid)+nn,vals(k)) = 1; 
end 

% Create the orientation angles 
orientim = (pi)*positions; 

% Calculate and store the true distance
true_distances(sc,1) = sqrt(2)*4; 

% Store the binary image 
syn_positions{sc,1} = positions; 

% Store orientation angles 
syn_angles{sc,1} = orientim;  

clear positions orientim 

%% Synthetic 4
% Set the case
sc = sc + 1; 

% 5 vertical pixels all exactly 90 degrees with variability in positions
description_txt{sc,1} = ...
    'vertical pixels, positional variability, no angle variability';

% Set the synthetic image to be 7x7 pixels
sze = 7; 
positions = zeros(sze,sze); 
bnds = 1; 
mid = sze/2 + 0.5; 

% Create positions 
vals = (1+bnds):(sze-bnds); 
for k = 1:length(vals)
    if mod(k,2) == 0
        nn = 0;
    else
        nn = 1; 
    end 
    positions(vals(k),round(mid)+nn) = 1; 
end 

% Create the orientation angles 
orientim = (pi/2)*positions; 

% Calculate and store the true distance
true_distances(sc,1) = sqrt(2)*4; 

% Store the binary image 
syn_positions{sc,1} = positions; 

% Store orientation angles 
syn_angles{sc,1} = orientim;  

clear positions orientim 

%% Synthetic 5 
% Set the case
sc = sc + 1; 

% 5 vertical pixels all with variabiltiy around 90 degrees
description_txt{sc,1} = ...
    'vertical pixels, no positional variability, angle variability';

% Set the synthetic image to be 7x7 pixels
sze = 7; 
positions = zeros(sze,sze); 
bnds = 1; 
mid = sze/2 + 0.5; 

% Create positions 
positions((1+bnds):(sze-bnds), round(mid)) = 1; 

% Variability between angles
dp_val = 0.93; var_val = acos(dp_val)/2; 
var_min = -var_val;
var_max = var_val;
rand_mat = (var_max-var_min).*rand(size(positions)) + var_min;

% Create the orientation angles with variability in the vector 
orientim = (pi/2) + rand_mat; 
orientim = orientim.*positions; 

% Correct the orientation anglse  
orientim = correctAngles(orientim);

% Calculate and store the true distance
true_distances(sc,1) = sqrt( (mid - mid)^2 + ((1+bnds)-(sze-bnds))^2 ); 

% Store the binary image 
syn_positions{sc,1} = positions; 

% Store orientation angles 
syn_angles{sc,1} = orientim;  

clear positions orientim 


%% Synthetic 6
% Set the case
sc = sc + 1; 

% 5 horizontal pixels all with variabiltiy around 180 degrees
description_txt{sc,1} = ...
    'horizontal pixels, no positional variability, angle variability';

% Set the synthetic image to be 7x7 pixels
sze = 7; 
positions = zeros(sze,sze); 
bnds = 1; 
mid = sze/2 + 0.5; 

% Create positions 
positions(round(mid),(1+bnds):(sze-bnds)) = 1; 

% Variability between angles 
dp_val = 0.93; var_val = acos(dp_val)/2; 
var_min = -var_val;
var_max = var_val;
rand_mat = (var_max-var_min).*rand(size(positions)) + var_min;

% Create the orientation angles with variability in the vector 
orientim = (pi) + rand_mat; 
orientim = orientim.*positions; 

% Correct the orientation anglse  
orientim = correctAngles(orientim);

% Calculate and store the true distance
true_distances(sc,1) = sqrt( (mid - mid)^2 + ((1+bnds)-(sze-bnds))^2 ); 

% Store the binary image 
syn_positions{sc,1} = positions; 

% Store orientation angles 
syn_angles{sc,1} = orientim;  

clear positions orientim 

%% Synthetic 7
% Set the case
sc = sc + 1; 

% 5 horizontal pixels with variability around 180 degrees with variability 
% in positions
description_txt{sc,1} = ...
    'horizontal pixels, positional variability, angle variability';

% Set the synthetic image to be 7x7 pixels
sze = 7; 
positions = zeros(sze,sze); 
bnds = 1; 
mid = sze/2 + 0.5; 

% Create positions 
vals = (1+bnds):(sze-bnds); 
for k = 1:length(vals)
    if mod(k,2) == 0
        nn = 0;
    else
        nn = 1; 
    end 
    positions(round(mid)+nn,vals(k)) = 1; 
end 

% Variability between angles 
dp_val = 0.93; var_val = acos(dp_val)/2; 
var_min = -var_val;
var_max = var_val;
rand_mat = (var_max-var_min).*rand(size(positions)) + var_min;

% Create the orientation angles with variability in the vector 
orientim = (pi) + rand_mat; 
orientim = orientim.*positions;  

% Correct the orientation anglse  
orientim = correctAngles(orientim);

% Calculate and store the true distance
true_distances(sc,1) = sqrt(2)*4; 

% Store the binary image 
syn_positions{sc,1} = positions; 

% Store orientation angles 
syn_angles{sc,1} = orientim;  

clear positions orientim 

%% Synthetic 8
% Set the case
sc = sc + 1; 

% 5 vertical pixels with variability around 90 degrees with variability in
% positions
description_txt{sc,1} = ...
    'vertical pixels, positional variability, angle variability';

% Set the synthetic image to be 7x7 pixels
sze = 7; 
positions = zeros(sze,sze); 
bnds = 1; 
mid = sze/2 + 0.5; 

% Create positions 
vals = (1+bnds):(sze-bnds); 
for k = 1:length(vals)
    if mod(k,2) == 0
        nn = 0;
    else
        nn = 1; 
    end 
    positions(vals(k),round(mid)+nn) = 1; 
end 

% Variability between angles 
dp_val = 0.93; var_val = acos(dp_val)/2; 
var_min = -var_val;
var_max = var_val;
rand_mat = (var_max-var_min).*rand(size(positions)) + var_min;

% Create the orientation angles with variability in the vector 
orientim = (pi/2) + rand_mat; 
orientim = orientim.*positions; 

% Correct the orientation anglse  
orientim = correctAngles(orientim);

% Calculate and store the true distance
true_distances(sc,1) = sqrt(2)*4; 

% Store the binary image 
syn_positions{sc,1} = positions; 

% Store orientation angles 
syn_angles{sc,1} = orientim;  

clear positions orientim 

%% Save data in a .mat file and include today's date
% Save the current path 
save_path = pwd; 

% Get today's date
date_format = 'yyyymmdd';
today_date = datestr(now,date_format);

% Create a summary file name 
save_name = strcat('czl_testcases',today_date,'.mat'); 

% Make sure the filename is unique 
[ save_name ] = appendFilename( save_path,...
    save_name);

% Save the data 
save(fullfile(save_path, save_name), ...
        'true_distances', 'syn_positions', 'syn_angles','description_txt');
    
%% Create function to correct angles 

function [theta_corrected] = correctAngles(theta_mat)
% This function will either add or subtract pi if the angles are less than
% 0 or greater than pi

% Initialize too small or too great matrices
tooGreat = zeros(size(theta_mat)); 
tooSmall = zeros(size(theta_mat)); 

% Create the too great and too small binary matrices
tooGreat( theta_mat > pi ) = 1; 
tooSmall( theta_mat < 0 ) = 1;

% Multiple by the correction 
tooGreat = -pi*tooGreat; 
tooSmall = pi*tooSmall; 

% Add the matrices to the theta matrix
theta_corrected = theta_mat + tooGreat + tooSmall; 

end



    