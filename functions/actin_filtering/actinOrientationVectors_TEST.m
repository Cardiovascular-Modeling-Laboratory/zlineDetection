
%Get the ridge orientations using top hat filtering
[orientim_tophat, reliability_tophat] = ridgeorient(CEDtophat, ...
    Options.sigma, Options.rho, Options.rho);

%Get the ridge orientations using the diffusion filtering. 
[orientim_anisodiffuse, reliability_anisodiffuse] = ridgeorient(CEDgray, ...
    Options.sigma, Options.rho, Options.rho);

%Bianrize actin image
actinBW = imbinarize(CEDgray);

%%
spacing = 10; 
color_spec = 'g'; 

%Tophat + reliability 
reliability_binary_tophat = reliability_tophat > ...
    settings.reliability_thresh;
orientim_reliability_tophat = orientim_tophat.*reliability_binary_tophat;
figure; imshow(actin_im); hold on; 
plotOrientationVectors(orientim_reliability_tophat, spacing, color_spec);
%Tophat + binarization 
orientim_binarization_tophat = orientim_tophat;
orientim_binarization_tophat(actinBW == 0) = 0; 
figure; imshow(actin_im); hold on; 
plotOrientationVectors(orientim_binarization_tophat, spacing, color_spec);
%Diffusion + reliability 
reliability_binary_anisodiffuse = reliability_anisodiffuse >...
    settings.reliability_thresh;
orientim_reliability_anisodiffuse = orientim_anisodiffuse.*...
    reliability_binary_anisodiffuse;
figure; imshow(actin_im); hold on; 
plotOrientationVectors(orientim_reliability_anisodiffuse, spacing, color_spec);
%Diffusion + binarization 
orientim_binarization_anisodiffuse = orientim_anisodiffuse;
orientim_binarization_anisodiffuse(actinBW == 0) = 0; 
figure; imshow(actin_im); hold on; 
plotOrientationVectors(orientim_binarization_anisodiffuse, spacing, color_spec); 
