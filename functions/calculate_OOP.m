function [ OOP, directionAngle, direction_error ] = ...
    calculate_OOP( angles_matrix )
%Function to calculate the OOP code, which is based on the 
%orientationalOrder_Matrix_function from OOP_MultipleCond 

%Reshape the matrix and remove all zero values. 
reshaped_matrix = angles_matrix(:); 
reshaped_matrix(reshaped_matrix == 0) = []; 

r = zeros(2, length(reshaped_matrix));

%Calculate x and y components of each vector r
    r(1,:) = cos(reshaped_matrix);
    r(2,:) = sin(reshaped_matrix);
        
        
%Calculate the Orientational Order Tensor for each r and 
%the average Orientational Order Tensor (OOT_Mean)
for i=1:2
    for j=1:2
        OOT_All(i,j,:)=r(i,:).*r(j,:);
        OOT_Mean(i,j) = mean(OOT_All(i,j,:));
    end
end

%Normalize the orientational Order Tensor (OOT), this is 
%necessary to get the order paramter in the range from 0 to 1
OOT = 2.*OOT_Mean - eye(2);

%Find the eigenvalues (orientational parameters) and 
%eigenvectors (directions) of the Orientational Order Tensor
[directions,orient_parameters]=eig(OOT);

%Orientational order parameters is the maximal eigenvalue, while the
%direcotor is the corresponding eigenvector.
[OOP,I] = max(max(orient_parameters));
director = directions(:,I);

%Calculate the angle corresponding to the director, note that by symmetry
%the director = - director. This implies that any angle with a period of
%180 degrees will match this director. To help compare these results to
%the plot results we enforce the period to match the period of the
%original data.
directionAngle_default = acosd(director(1)/sum(director.^2));
directionAngle = directionAngle_default+180*(floor(min(reshaped_matrix)/pi()));

%Calculate the difference between the director and the mean of the
%angles. Note, that these are not necessarily the same thing because we
%have a finite number of vectors, so there is some inacuracy introduced
%in both methods. We can expect the difference to be very large for
%isotropic and small for well aligned structures. The output of this is
%suppressed unless someone needs it for something.
direction_error = directionAngle-(180/pi())*mean(reshaped_matrix);


end
