function [ distances ] = coordinate_distances( x_values, y_values)
%Input the x and y coordinates that you would like to know the distance of.
%The output will be a matrix of the distances between each coordinate and
%every other coordinate. 
%Example: 
% x_values =[ 1     2     3     4]
% y_values = [6     2     1     3]
% reshape_dist = 
%          0    4.1231    5.3852    4.2426
%     4.1231         0    1.4142    2.2361
%     5.3852    1.4142         0    2.2361
%     4.2426    2.2361    2.2361         0

%Calculate the distance between any ordered pair and every other one. 
%Repeat x and y values 
col_xvalues = x_values; 
rows_xvalues= x_values'; 

col_yvalues = y_values; 
rows_yvalues= y_values';

%Anonymous functions to calculate the distance by first taking the 
%difference between the two x points and the two y points and then 
%taking the squareroot of the sum. 
fun_diff_2 = @(a,b) (a-b).^2; 
fun_dist = @(a_diff_2, b_diff_2) sqrt(a_diff_2 + b_diff_2);

%Find the difference between the x and y values squared. 
x_diff_2 = bsxfun(fun_diff_2, col_xvalues, rows_xvalues); 
y_diff_2 = bsxfun(fun_diff_2, col_yvalues, rows_yvalues); 

%Calculate the total distance
distances = bsxfun(fun_dist, x_diff_2, y_diff_2); 

end