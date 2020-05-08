function [tf] = doStringComparison(STR,PATTERN)
% Check if the contains function exists in this version of MATLAVB
if ~exist('contains')
    useContains = false;
    if ~exist('strfind')
        useStrfind = false; 
    else
        useStrfind = true; 
    end 
else
    useContains = true; 
    useStrfind = false; 
end 


if useContains
    tf = contains(STR,PATTERN); 
end 

if useStrfind
    tf = ~isempty(strfind(STR,PATTERN)); 
end 
    
end

