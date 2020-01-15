% sortFilenames - Compare two sets of filenames and sort them based on the
% values within them 
% 
% Usage: 
%  createSummaries(MultiCS_Data, name_CS, zline_images,...
%    zline_path, cond, settings)
%
% Arguments:
%   set1
%   set2
%   exclusions
% 
% Returns:
%   sorted_set1
%   sorted_set2
%   comp_matrix
%   together_vis
%
% Dependencies: 
%   MATLAB Version >= 9.5 
%   Functions: 
%       compareFileNumbers.m
%
% Tessa Morris
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [sorted_set1,sorted_set2, comp_matrix, together_vis] = ...
    sortFilenames(set1, set2, exclusions)
%Get the number of filenames in both sets 
n1 = length(set1); 
n2 = length(set2); 

if iscolumn(set1)
    set1 = set1'; 
end 

if iscolumn(set2)
    set2 = set2'; 
end 

%Double check that the length of the two sets of filenames are the same. 
if n1 ~= n2
    %Display a warning 
    disp('Filename sets are not the same size.'); 
else
   %Create a matrix to store differences between filenames. 
   %Save the number and the maximum 
   %n1: set1 filename; n2: set2 filename; (:,:,1): number of differences 
   %(:,:,2): absolute value of maximum difference 
   comp_matrix = zeros(n1,n2,2); 
   for p1 = 1:n1
       for p2 = 1:n2
           %Compare filenumbers
           [~, n_diff, max_diff]  = ...
                compareFileNumbers(set1{p1},set2{p2}, false, ...
                    exclusions); 
           comp_matrix(p1,p2,1) = n_diff;
           if ~isempty(max_diff)
            comp_matrix(p1,p2,2) = max_diff;
           else
               comp_matrix(p1,p2,2) = 0; 
           end 
       end 
   end 
end 

%Find the positions that have the minimum number of differences 
ndiff = comp_matrix(:,:,1); 
[d1, d2] = find( ndiff == min(ndiff(:)) );  

%Initialize sorted sets. 
sorted_set1 = cell(1,n1); 
sorted_set2 = cell(1,n2); 
%Visualize together 
together_vis = cell(n1,2); 
%If there is only one minimum per filename and they're all unique, 
%order them based on the d1,d2 organization 
if length(d1) == n1 && length(unique(d1)) == n1 && length(unique(d2)) == n2 
    for k = 1:n1
        sorted_set1{1,k} = set1{1,d1(k)}; 
        sorted_set2{1,k} = set2{1,d2(k)}; 
        together_vis{k,1} = set1{1,d1(k)};
        together_vis{k,2} = set2{1,d2(k)}; 
    end
else 
    %Find the positions that have the minimum number of differences 
    min_diff = comp_matrix(:,:,2); 
    [m1, m2] = find( min_diff == min(min_diff(:)) );  
    if length(m1) == n1 && length(unique(m1)) == n1 && ...
            length(unique(m2)) == n2 
        for k = 1:n1
            sorted_set1{1,k} = set1{1,m1(k)}; 
            sorted_set2{1,k} = set2{1,m2(k)}; 
            together_vis{k,1} = set1{1,m1(k)};
            together_vis{k,2} = set2{1,m2(k)}; 
        end
    else
        disp('The files cannot be properly matched with the current naming scheme.'); 
        % Set the sorted set equal to the input set 
        sorted_set1 = set1; 
        sorted_set2 = set2; 
        % Loop through and create the together visualization  
        for k = 1:n1
            together_vis{k,1} = sorted_set1{1,k};
            together_vis{k,2} = sorted_set2{1,k}; 
        end 
    end
end

end

