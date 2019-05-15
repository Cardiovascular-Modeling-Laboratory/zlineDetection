function [all_combinations] = combineStrings(string1,string2)
%Length of strings and total combinations 
len1 = length(string1); 
len2 = length(string2); 
tot = len1*len2; 
all_combinations = cell(1,tot); 
n = 1; 
for k1 = 1:len1
    for k2 = 1:len2
        all_combinations{1,n} = strcat(string1{k1}, string2{k2}); 
        n = n+1; 
    end
end
end