function [sorted_set1,sorted_set2] = sortFilenames(set1, set2)
%Get the number of filenames in both sets 
n1 = length(set1); 
n2 = length(set2); 

%Double check that the length of the two sets of filenames are the same. 
if n1 ~= n2
    %Display a warning 
    disp('Filename sets are not the same size.'); 
else
   %Create a matrix to store how similar all of the filenames are, meaning
   %how many transformations need to be made to covert one filename to
   %another. 
   
end 
end

