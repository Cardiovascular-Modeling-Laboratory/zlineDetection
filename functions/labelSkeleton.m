function [ labeled_im ] = labelSkeleton( im, skel )
%Function to add color onto grayscale image were skeleton is

%Save the image as individual RGB channels
RChannel = im;
GChannel = im;
BChannel = im;

%Yellow triplet is [1 1 0]. Set channels where the skeleton is positive
RChannel(skel == 1) = 1; 
GChannel(skel == 1) = 1; 
BChannel(skel == 1) = 0; 

%Concatinate into a labeled image
labeled_im(:,:,1) = RChannel;
labeled_im(:,:,2) = GChannel;
labeled_im(:,:,3) = BChannel;

end

