function [nuclei_probabilities, nuclei_labels] = ...
    classifyCMNuclei(nuclei_im, nuclei_binary,  labels)

%Add in boundaries instead of nuclei and label 
% in = inpolygon(xq,yq,xv,yv)
% [in,on] = inpolygon(xq,yq,xv,yv)
% plot(xv,yv) % polygon
% axis equal
% 
% hold on
% plot(xq(in),yq(in),'r+') % points inside
% plot(xq(~in),yq(~in),'bo') % points outside

%Convert nuclei image to be 2D grayscale matrix 
if size(nuclei_im,3) > 1
    nuclei_im = rgb2gray(nuclei_im); 
else
    nuclei_im = mat2gray(nuclei_im); 
end 

%Eventually I want to get a rpoabability for each nulcie 
nuclei_probabilities = []; 

%Determine where labels are equal to 1
nuclei_labels = zeros(size(nuclei_im)); 

%Blue channel is nuclei 
B = nuclei_im; 

%Green channel is where there is a CM (labels == 3)
G = labels; 
G(labels~=3) = 0; 
G(nuclei_binary == 0) = 0; 

%Red chennal is where there is no CM (labels == 1)
R = labels; 
R(labels~=1) = 0; 
R(nuclei_binary == 0) = 0; 

%Open the nuclei fig 
nuc_fig = zeros(size(nuclei_im,1),size(nuclei_im,2),3); 
nuc_fig(:,:,1) = R; 
nuc_fig(:,:,2) = G; 
nuc_fig(:,:,3) = B; 

figure; 
imshow(nuc_fig); 

end

