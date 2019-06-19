% combineStrings - Concatinate every combination of string1{i} + string2{j}
%
% Usage:
%   all_combinations = combineStrings(string1,string2); 
%
% Arguments:
%   string1             - Cell containing strings 
%                           Class Support: Cell of STRINGs
%   string2             - Cell containing strings 
%                           Class Support: Cell of STRINGs
% Returns:
%   all_combinations    - name of a directory that does not exist 
%                           Class Support: Cell of size 
%                           1 x length(string1)*length(string2) of STRINGS
%
% Dependencies: 
%   MATLAB Version >= 9.5 
%
% Tessa Morris
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

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
