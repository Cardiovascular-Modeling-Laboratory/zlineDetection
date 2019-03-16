function [ im, bw, mask ] = createActinMask( im , disk_size)
%Disk size 10 seems to work best for our data 
%Convert image to grayscale 
if size(im,3) > 1
    im = rgb2gray(im); 
else
    im = mat2gray(im);
end 

%Normalize image to have 0 mean and unit standard deviation 
im=im-mean(im(:));
im=im/std(im(:));

%Convert to binary 
bw = imbinarize(im); 

%Dilate binary image with a disk structure 
mask =imdilate( bw, strel( 'disk', disk_size ) );
end

