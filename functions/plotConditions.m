function [ condition_values, mean_condition,std_condition ] =...
    plotConditions(data_points, descriptors,...
    cond_names, plot_names, additional_descriptors)

%If there are additional descriptions deal with that.
%Otherwise


%Save the number of condition names 
n_cond = length(cond_names); 

%Condition_values 
condition_values = cell(length(cond_names),1); 
mean_condition = zeros(length(cond_names),1); 
std_condition = zeros(length(cond_names),1); 

%Create x-axis
xaxis = 1:1:length(cond_names); 

%Open a figure
figure; 
hold on; 

%Colors
colors = {[1,0.6,1], [0.2,0.6,1], [0.6275,0.6275,0.6275], 'r','g'};

%Start c counts 
c = 1; 

%Loop through all of the conditions 
for k = 1:n_cond
    
    %Values to exclude
    exclude_vals = zeros(size(descriptors)); 
    exclude_vals(descriptors ~=k) = NaN; 
    %Transpose
    exclude_vals = exclude_vals'; 
    
    %Repeat the values for 
    exclude_vals = repmat(exclude_vals, [size(data_points,1), 1]);  
    
    %Add the values plus the points to exclude 
    include_vals = data_points + exclude_vals; 
    
    
    %Reshape and remove NaN values
    include_vals = include_vals(:);
    include_vals(isnan(include_vals)) = []; 
    
    %Save data 
    condition_values{k,1} =include_vals; 
    mean_condition(k,1) = mean(include_vals); 
    std_condition(k,1) = std(include_vals); 

    %Plot all of the points 
    plot(xaxis(k)*ones(size(condition_values{k,1})),...
        condition_values{k,1},'.',...
        'MarkerSize', 8, ...
        'MarkerEdgeColor',colors{c},...
        'MarkerFaceColor',colors{c});

    %Plot the mean 
    temp_x = (xaxis(k)-0.45):0.01:(xaxis(k) + 0.45); 
    disp(temp_x); 
    plot(temp_x, mean_condition(k,1)*ones(size(temp_x)), ...
        '-','color',colors{c},'LineWidth',2);

    %Plot range of orientation values 
    hold on; 
    fill([min(temp_x), max(temp_x),max(temp_x), min(temp_x)], ...
        [mean_condition(k,1)-std_condition(k,1),...
        mean_condition(k,1)-std_condition(k,1), ...
        mean_condition(k,1)+std_condition(k,1), ...
        mean_condition(k,1)+std_condition(k,1)], ...
        colors{c}, 'FaceAlpha', 0.3,'linestyle','none');

    %Increase color 
    if c < length(colors)
        c = c+1; 
    else
        c = 1; 
    end 
end 

buffer = 0.3*min(data_points(:)); 
if buffer < 0.1
    buffer = 0.1; 
end 

%Get the minimum and max median values 
ymin = min(data_points(:)) - buffer; 
ymax = max(data_points(:)) + buffer; 



%Change axis labels
ylim([ymin ymax]); 
xlim([min(xaxis)-1 max(xaxis)+1]); 
set(gca,'XTick',xaxis) 
set(gca,'XTickLabel',cond_names)
set(gca, 'fontsize',12,'FontWeight', 'bold');
xlabel(plot_names.x,'FontSize', 14, 'FontWeight', 'bold');
ylabel(plot_names.y,'FontSize',...
    14, 'FontWeight', 'bold');
title(plot_names.title,...
    'FontSize', 14, 'FontWeight', 'bold')

%Save file 
saveas(gcf, fullfile(plot_names.path, plot_names.savename), 'pdf');



end

