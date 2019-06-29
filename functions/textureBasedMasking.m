% Compute histogram of oriented graidents. 
sigma = 0.5; 
blk_size = 15; 
ohist = hog2( I, sigma , blk_size); 

% Calculate the average in each grid 
ohist_avg = mean(ohist,3); 

% Initial binarization 
bw1 = zeros(size(ohist_avg)); 
bw1(ohist_avg > 0) = 1; 

% Fill holes 
bw2 = imfill(bw1, 'holes'); 

% Remove noise 
noise_size = 1*8;
bw3 = bwareaopen( bw2, noise_size );

% Dilate and then erode 
disk_sze = 1; 
se = strel('disk',disk_sze);
bw4 = imdilate(bw3, se); 
% bw5 = imerode(bw4, se);
bw5 = bw4; 
bw6 = bw5; 
figure; imshow(bw6); 

% Resize
bw7 = imresize(bw6, size(I));
bw7(bw7 > 0) = 1; 
% Get only the false parts of bw6
bw6f = I; 
bw6f(bw7 == 1) = 0; 
figure; imshow(bw6f); 

per_rem = sum(bw7(:))/(size(I,1)*size(I,2)); 
per_rem = per_rem*100; 
disp(per_rem); 
