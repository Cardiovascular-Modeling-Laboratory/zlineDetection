function [diff, n_diff, diff_values]  = ...
    compareFileNumbers(filename1,filename2, dispmsg)
% This function will be used to compare the numbers in two files. It will
% then tell you the difference between the numbers and output the total
% difference between them 

%Compare extensions
%Remove any of the strings to remove

%If the user did not supply a third input set dispmsg to false. 
if nargin < 3
    dispmsg = false; 
end 

%Use Matlab string compare to see if the strings are exactly the same. 
if strcmp(filename1,filename2)
    %If the strings are identical, set the distance equal to 0
    diff = 0; 
    n_diff = 0; 
    diff_values = NaN; 
    if dispmsg
        disp('No differences between numbers.'); 
    end 
else
    %Isolate the characters
    char1 = regexprep(filename1,'[^a-zA-Z]','');
    char2 = regexprep(filename2,'[^a-zA-Z]','');
    %Compare the string portion of the filenames  
    if strcmp(char1, char2)
        chardiff = 0; 
        if dispmsg
            disp('No differences between characters.'); 
        end 
    else
        %Store the values 
        char1 = char(char1); 
        char2 = char(char2); 
        
        %Get the lenths of both 
        cl = length(char1); 
        c2 = length(char2); 
        
        %Create a matrix to store the differences between characters
        chardiff = zeros(c1+1, c2+1); 
        chardiff(:,1) = (0:c1)';
        chardiff(1,:) = (0:c2);
    %     for i = 1:m
    %         for j = 1:n
    %             c = s(i) ~= t(j); % c = 0 if chars match, 1 if not.
    %             D(i+1,j+1) = min([D(i,j+1) + 1
    %                               D(i+1,j) + 1
    %                               D(i,j)  +  c]);
    %         end
    %     end
    %     levm_print(s,t,D)    
    %     d = D(m+1,n+1);
    %         end    

        
        
        disp('Characters are also different.'); 
    end 
    
    %Isolate the numbers in the filenames 
    nums1 = regexp(filename1,'\d*','Match');
    nums2 = regexp(filename2,'\d*','Match'); 
    
    %Get the length of both cells
    len1 = length(nums1); 
    len2 = length(nums2);
    
    %If the lengths are the same compare the differences 
    if len1 == len2 
        %Array to save difference 
        diff = zeros(size(nums1)); 
        %Compute differences 
        for l = 1:len1
            diff(l) = str2double(nums1{1,l}) - str2double(nums2{1,l}); 
        end 
        
        %Number of differences 
        diff_values = diff; 
        diff_values(diff_values == 0) = []; 
        n_diff = length(diff_values); 
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
            disp(diff_values); 
            disp(filename1); 
            disp(filename2); 
        end 
    end 
end 

end
     