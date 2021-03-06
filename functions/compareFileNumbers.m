% compareFileNumbers - Compare all of the numbers in two files.
% It will exclude any of the following strings in exclusions 
%
% Usage:
%   [diff_values, n_diff, max_diff]  = ...
%    compareFileNumbers(filename1,filename2, dispmsg, exclusions)
%
% Arguments:
%   filename1       - filename to compare 
%                       Class Support: STRING
%   filename2       - filename to compare 
%                       Class Support: STRING
%   dispmsg         - [optional] display results of comparions 
%                       Class Support: LOGICAL  
%   exclusions      - [optional] cell that has strings to exclude 
%                       Class Support: Cell of strings 
%
% Returns:
%   diff_values     - numeric differences between each number 
%                       Class Support: array of numbers 
%   n_diff          - number of differences 
%                       Class Support: double 
%   max_diff        - value of the maximum difference 
%                       Class Support: double 
%
% Dependencies: 
%   MATLAB Version >= 9.5 
%
% Tessa Morris
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [diff_values, n_diff, max_diff]  = ...
    compareFileNumbers(filename1,filename2, dispmsg, exclusions)

filename1_edit = filename1; 
filename2_edit = filename2; 

% Remove any of the exlusions if it is declared 
if nargin > 3
    for k = 1:length(exclusions)
        filename1_edit = strrep(filename1_edit, exclusions{k}, ''); 
        filename2_edit = strrep(filename2_edit, exclusions{k}, '');
    end
end 

%If the user did not supply a third input set dispmsg to false. 
if nargin < 3
    dispmsg = false; 
end 

%Use Matlab string compare to see if the strings are exactly the same. 
if strcmp(filename1_edit,filename2_edit)
    %If the strings are identical, set the distance equal to 0
    diff_values = NaN; 
    n_diff = 0; 
    max_diff = 0; 
    if dispmsg
        disp('No differences between filenames.'); 
    end 
else
    %Isolate the numbers in the filenames 
    nums1 = regexp(filename1_edit,'\d*','Match');
    nums2 = regexp(filename2_edit,'\d*','Match');
    
    %Get the length of both cells
    len1 = length(nums1); 
    len2 = length(nums2);
    
    %If the lengths are the same compare the differences 
    if len1 == len2 
        %Array to save difference 
        diff_values = zeros(size(nums1)); 
        %Compute differences 
        for l = 1:len1
            diff_values(l) = str2double(nums1{1,l}) - str2double(nums2{1,l}); 
        end 
        
        %Number of differences 
        diff = diff_values; 
        diff(diff == 0) = []; 
        n_diff = length(diff);
        total_nums = len1; 
        
        %Display results if requested
        if dispmsg
            %Display message options based on 1 or more. 
            if n_diff == 1
                con_word = 'was';
                am = 'amount:';
            else
                con_word = 'were'; 
                am = 'amounts:'; 
            end 

            msg = strcat('Out of ',{' '}, num2str(total_nums), {' '}, ...
                'numbers,', {' '}, num2str(n_diff), {' '}, con_word, ...
                ' different by the following ',{' '}, am); 
            disp(msg{1}); 
            disp(diff); 
            disp(filename1); 
            disp(filename2);
        end
        
        %Save the max difference
        max_diff = max(abs(diff)); 
            
    else
        %Display results if requested
        if dispmsg
            disp('Not the same amount of numbers'); 
        end
        
        % Set all of hte results equal to NaN 
        diff_values = NaN; 
        n_diff = NaN; 
        max_diff = NaN; 
        
    end 
end 

end
     