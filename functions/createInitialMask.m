function [ im, bw, mask ] = createInitialMask( im , disk_size)
%Disk size 10 seems to work best for our data 
% %Convert image to grayscale 
% if size(im,3) > 1
%     im = rgb2gray(im); 
% else
%     im = mat2gray(im);
% end 
% 
% %Normalize image to have 0 mean and unit standard deviation 
% im=im-mean(im(:));
% im=im/std(im(:));

%Convert to binary using both adaptive and normal thresholding
bw1 = imbinarize(im,'adaptive','Sensitivity',1); 
bw2 = imbinarize(im); 

%Create binary matrix where both binarizations are 1 
bw = zeros(size(im)); 
bw( bw1==true & bw2==true ) = 1;

%Dilate binary image with a disk structure 
mask =imdilate( bw, strel( 'disk', disk_size ) );

%Get the number of pixels that are 0,1,and total 
im_mask = zeros(size(im)); 
im_mask(mask ==1) = 1; 
pos_pix = sum(im_mask(:)); 
tot_pix = size(im,1)*size(im,2); 
disp(pos_pix/tot_pix); 
end

