function [] = plotSLhist(d_micron_NZ,d_mean,d_stdev)
h = histogram(d_micron_NZ); hold on; 
% Get the maximum value 
max_binval = max(h.Values); 
min_binval = min(h.Values); 

bin_vals = h.BinEdges; 
b = 1; 
while d_mean > bin_vals(b)
    b = b+1; 
end 
disp(d_mean); 
disp(bin_vals(b)); 

% y position 
y_pos = mean([max_binval, max([bin_vals(b-1), bin_vals(b)])]); 
y_sp = round(0.05*(max_binval-min_binval),2); 
min_y = y_pos - y_sp; 
max_y = y_pos + y_sp; 

% Bars for standard deviaiton 
y_vals = [min_y, max_y, y_pos, y_pos, min_y, y_pos, max_y];

%Get the minimum and max values 
min_binval = d_mean - d_stdev;
max_binval = d_mean + d_stdev; 
% Mean and standard deviation 
x_vals = [max_binval, max_binval, max_binval, min_binval, min_binval, min_binval,...
    min_binval]; 


%Plot the standard deviation bars  
plot(x_vals, y_vals,'-','color','k','LineWidth',2);
plot(d_mean, y_pos ,'o','MarkerSize',5,'MarkerEdgeColor', 'k',...
'MarkerFaceColor', 'k'); 
set(gca, 'FontSize',12,'FontWeight','bold'); 
set(gca,'TickDir','out');
xlabel('Sarcomere Length (\mu m)','FontSize',14, 'FontWeight','bold');
ylabel('Count','FontSize',14, 'FontWeight','bold');

% Set title 
title_string = strcat('Mean Sarcomere Length:',{' '},...
    num2str(round(d_mean,2)),{' '},'\pm',{' '},num2str(round(d_stdev,2)));
title(title_string, 'FontSize',14, 'FontWeight','bold');
end

