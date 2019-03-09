function [cm_fig,noz] = ...
    plotCardiomyocyteResults(actin_im,zline_im, labels)

%Convert actin and zline images to grayscale
if size(actin_im,3) > 1
    actin_im = rgb2gray(actin_im); 
else
    actin_im = mat2gray(actin_im); 
end 
if size(zline_im,3) > 1
    zline_im = rgb2gray(zline_im); 
else
    zline_im = mat2gray(zline_im); 
end 

%Get red channel - zlines 
R = zline_im; 
%Get green channel - actin 
G = actin_im; 
%Get blue channel (no z-lines) 
B1 = labels; 
B1(B1 ~= 1) = 0; 
%Get blue channel (no actin) 
B2 = labels; 
B2(B2 ~= 2) = 0; 

%Create figures
cm_fig = zeros(size(actin_im,1),size(actin_im,2),3); 
cm_fig(:,:,1) = R; 
cm_fig(:,:,2) = G; 
cm_fig(:,:,3) = B1; 

noz = cm_fig; 
noz(:,:,3) = B2; 

figure; 
imshow(cm_fig); 
figure; 
imshow(noz); 
end

