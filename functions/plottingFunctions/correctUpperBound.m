% correctUpperBound - Determines if a number is greater than an upperbound,
% if it is, that number will be set to the provided value. If there is no
% provided value it will be set to the upperbound 
%
% Usage: 
%   num = 4; upperbound = 3; 
%   num = correctUpperBound(num,upperbound);  
%   % Result: num = 3
%
% Arguments:
%   num         - Number to correct
%                   Class Support: one number 
%
%   upperbound  - Upperbound of value 
%                   Class Support: one number 
%       
%   num_def     - (OPTIONAL) Value to set num to if it is greater than the
%                   upperbound
%                   Class Support: one number 
% Returns:
%   num         - Corrected number  
%                   Class Support: one number 
%
% Dependencies: 
%   MATLAB Version >= 9.5 
%
% Tessa Altair Morris
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 
function [num] = correctUpperBound(num,upperbound,num_def)
% If the user did not provide a value to set the number to, set it to the
% upper bound
if nargin == 2
    num_def = upperbound; 
end 

% Check to see if the number is greater than the upperbound. If it is, set
% it to be the default number 
if num > upperbound
    num = num_def; 
end 
end

