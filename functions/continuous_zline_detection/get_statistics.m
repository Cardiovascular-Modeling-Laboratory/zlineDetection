function [ stat_summary ] = get_statistics( data )
%This function will output the total, mean, standard deviation, median, 
%mode, min, and max. The purpose of this function is to easily analyze a
%given data set 

%Statistical Information
total = length(data); 
mean_data = mean(data); 
std_data = std(data); 
median_data = median(data);
mode_data = mode(data); 
min_data = min(data); 
max_data = max(data); 

%Create a labeled matrix. 
headers = {'Total', 'Mean', 'Standard Deviation', 'Median', 'Mode', ...
    'Min','Max'}; 
stat_numbers = [total(1), mean_data(1), std_data(1), median_data(1), ...
    mode_data(1), min_data(1), max_data(1)]; 
stat_summary = [headers; num2cell(stat_numbers)]; 
end

