function [extra_medians] = plotCSresults(MultiCS_lengths, MultiCS_CSN,...
    name_CS, MultiCS_grid_sizes, MultiCS_actin_threshs, plot_names)

%Get grid sizes 
grid_sizes = MultiCS_grid_sizes{1,1}; 
%Get thresholds 
actin_threshs = MultiCS_actin_threshs{1,1}; 

%Get the number of unique grid sizes and threshold values 
unique_grids = unique(grid_sizes); 
gn = length(unique_grids); 
unique_thresh = unique(actin_threshs); 
afn = length(unique_thresh); 

%Save the number of coverslips
ncs = size(MultiCS_CSN,2); 

%Write CS values
cs_values = zeros(1,ncs);
%Get the coverslip values 
for n = 1:ncs
    temp = MultiCS_CSN{1,n}; 
    cs_values(1,n) = temp(1,1); 
end 
%Condition_values 
condition_values = cell(gn*afn,1); 
mean_condition = zeros(gn*afn,1);
std_condition = zeros(gn*afn,1); 
median_condition = zeros(gn*afn,1);

%Get the upper (:,1) and lower (:,2) medians 
extra_medians = zeros(gn*afn,2);


%Open a figure
figure; 
hold on; 

%Get middle x value 
filter_x = zeros(size(unique_thresh));
f = 1; 

%Colors
colors = {[1,0.6,1], [0.2,0.6,1], [0.6275,0.6275,0.6275],...
    [0.5255,0.2588,0.9569], [0.6350, 0.0780, 0.1840],...
    [0.2549,0.9569,0.5137], [0.8500, 0.3250, 0.0980]};             
            
%Start color counts 
c = 0; 

%Start counts
k = 1; 

%Store bounds - mins = 1, max = 2
bnds = zeros(ncs*gn*afn,2); 

for g= 1:gn
    
    % Set up the grids to exclude 
    exclude_grid = zeros(size(grid_sizes)); 
    
    %Only open suplots if there is more than one grid
    if gn > 1
        subplot(gn,1,g); 
        hold on; 
        %Set the values that are not equal to the current grid size equal to
        %NaN. Otherwise, set the grid size to 1 
        exclude_grid(grid_sizes ~= unique_grids(g)) = NaN;     
    end 
    
    %Set position equal to 0 
    p = 0; 
    
    for a = 1:afn
        % Set up the thresholds to exclude 
         exlude_thresh = zeros(size(actin_threshs)); 
            
        if afn > 1
            %Set the values that are not equal to the current threshold
            %size equal to NaN. Otherwise, set the grid size to 1 
            exlude_thresh(actin_threshs ~= unique_thresh(a)) = NaN; 
        end 
        
        %Add the exclusion threshold and grids
        exlude_exploration = exclude_grid+exlude_thresh; 
        
        %Loop through all of the conditions 
        for n = 1:ncs 
            %Increase color 
            if c > length(colors)-1 || n == 1
                c = 1; 
            else
                c = c+1; 
            end 
 
            %Get the middle value
            x0 = (2*p+1)/2; 
           
            %Isolate the length 
            temp_CS = MultiCS_lengths{1,n}; 
            temp_len = temp_CS{1,~isnan(exlude_exploration)}; 

            %Save data and calculate the mean and standard deviation. 
            condition_values{k,1} =temp_len; 
            mean_condition(k,1) = mean(temp_len); 
            std_condition(k,1) = std(temp_len); 
            median_condition(k,1) = median(temp_len);
            
            %Get the median of the lower and upper halves of the data. This
            %will sort from smallest to largest
            temp_len = sort(temp_len(:)); 
            len = round(length(temp_len)/2); 
            extra_medians(k,1) = median(temp_len(len+1:end)); 
            extra_medians(k,2) = median(temp_len(1:len)); 
            
            % >> VIOLIN PLOTS 
            % Hoffmann H, 2015: violin.m - Simple violin plot using matlab
            % default kernel density estimation. 
            % INRES (University of Bonn), Katzenburgweg 5, 53115 Germany.
            % hhoffmann@uni-bonn.de
            % Calculate the kernel density 
            [pf, u] = ksdensity(temp_len); 
            
            %Normal kernel density 
            pf = pf/max(pf)*0.3; 
            
            %Plot the violin fill 
            fill([pf'+x0;flipud(x0-pf')],[u';flipud(u')],...
                colors{c}, 'FaceAlpha', 0.3,'linestyle','none');
            
            %Plot the mean 
            plot([interp1(u', pf'+x0, mean_condition(k,1)), ...
                interp1(flipud(u'), flipud(x0-pf'), ...
                mean_condition(k,1)) ],...
                [mean_condition(k,1) mean_condition(k,1)],...
                '-','color',colors{c},'LineWidth',2);

            %Plot the median 
            plot([interp1(u', pf'+x0, median_condition(k,1)), ...
                interp1(flipud(u'), flipud(x0-pf'), ...
                median_condition(k,1)) ],...
                [median_condition(k,1) median_condition(k,1)],...
                '-','color','k','LineWidth',2);

            %Plot upper and lower median 
            for s=1:2
                plot([interp1(u', pf'+x0, extra_medians(k,s)), ...
                interp1(flipud(u'), flipud(x0-pf'), ...
                extra_medians(k,s)) ],...
                [extra_medians(k,s) extra_medians(k,s)],...
                ':','color','k','LineWidth',2);
            end 
            
            %Save the mins and max lengths
            bnds(k,1) = min(temp_len); 
            bnds(k,2) = max(temp_len); 
            
            %Increate the count 
            k = k+1; 
            %Increase start and stop 
            p = p+1.5;
            
            if g== 1 && n == floor(ncs/2) 
                %Put axis in the middle of all the CS if there is an odd
                %number 
                if mod(ncs,2) == 0 
                    filter_x(1,f) = x0 + (1.5/2);
                else 
                    filter_x(1,f) = x0; 
                end 
                f = f+1; 
            end 
            
            if n == ncs
                p = p+1; 
            end 
    
        end
        
    end
end

%Set the axis limits for the y axis 
buffer = 0.3*min(bnds(:,1)); 
if buffer < 0.1
    buffer = 0.1; 
end 

% Start color counter
c = 0; 

%Get the minimum and max median values 
ymin = min(bnds(:,1)) - buffer; 
ymax = max(bnds(:,2)) + buffer; 

for g = 1:gn 
    %Only open suplots if there is more than one grid
    if gn > 1
        subplot(gn,1,g); 
        hold on; 
    end 
    
    %Change axis limits
    ylim([ymin ymax]); 
    xlim([-2 p+1]); 

    %Change the x axis labels
    set(gca,'XTick',filter_x) 
    set(gca,'XTickLabel',num2cell(unique_thresh))

    %Change the font size
    set(gca, 'fontsize',12,'FontWeight', 'bold');

    %Change the x and y labels 
    xlabel(plot_names.x,'FontSize', 14, 'FontWeight', 'bold');
    ylabel(plot_names.y,'FontSize',...
        14, 'FontWeight', 'bold');
    
    if gn > 1
        %Change the title
        new_title = strcat(plot_names.title, {' '}, 'Grid Size:',...
            {' '}, num2str(unique_grids(g))); 
        title(new_title,'FontSize', 14, 'FontWeight', 'bold'); 
    else
        %Change the title 
        title(plot_names.title,...
            'FontSize', 14, 'FontWeight', 'bold'); 
    end 
    
end

%Save file
saveas(gcf, fullfile(plot_names.path, plot_names.savename), 'pdf');

%Make legend
figure; 
hold on; 

%Start position tracker 
p = 0; 

% Mean points 
legend_cond = [1;2.5;3]; 
legend_mean = mean(legend_cond); 
legend_std = std(legend_cond);
legend_median = median(legend_cond); 
len = round(length(legend_cond)/2); 
legend_topmed = median(legend_cond(len+1:end)); 
legend_bottommed = median(legend_cond(1:len)); 

%Save labels 
vals = {plot_names.type,'Mean', 'Violin','Median',...
    'Top 50% Median','Bottom 50% Median'}; 

%Get legend titles 
legend_caption = cell(length(vals)*ncs,1); 
%Temporary titles 


%Counter for legend
l=1; 
for n = 1:ncs
    %Set the color 
    %Increase color 
    if c > length(colors)-1 || n == 1
        c = 1; 
    else
        c = c+1; 
    end 

    %Get the middle value
    x0 = (2*p+1)/2; 

    %Compute the x-axis
    x = p:p+1; 
    
    %Plot the medians 
    plot(x0*ones(size(legend_cond)),...
        legend_cond,'.',...
        'MarkerSize', 8, ...
        'MarkerEdgeColor',colors{c},...
        'MarkerFaceColor',colors{c});
    
    %Temporary legend name 
    temp_name = strcat('CS ',{' '}, name_CS(n,1), {' '}, vals{1}); 
    legend_caption{l,1} = temp_name{1,1}; 
    l = l+1; 
    
    %Plot the mean 
    plot(x, legend_mean*ones(size(x)), ...
        '-','color',colors{c},'LineWidth',2);
    
    %Temporary legend name 
    temp_name = strcat('CS ',{' '}, name_CS(n,1), {' '}, vals{2}); 
    legend_caption{l,1} = temp_name{1,1}; 
    l = l+1; 
    
    %Plot standard deviation 
    fill([p, p+1, p+1, p], ...
        [legend_mean-legend_std,...
        legend_mean-legend_std, ...
        legend_mean+legend_std, ...
        legend_mean+legend_std], ...
        colors{c}, 'FaceAlpha', 0.3,'linestyle','none');
   
    %Temporary legend name 
    temp_name = strcat('CS ',{' '}, name_CS(n,1), {' '}, vals{3}); 
    legend_caption{l,1} = temp_name{1,1}; 
    l = l+1; 
    
    %Plot the median 
    plot(x, legend_median*ones(size(x)), ...
        '-','color','k','LineWidth',2);
    temp_name = strcat('CS ',{' '}, name_CS(n,1), {' '}, vals{4}); 
    legend_caption{l,1} = temp_name{1,1}; 
    l = l+1; 
    
    %Plot the top 50% median 
    plot(x, legend_topmed*ones(size(x)), ...
        ':','color','k','LineWidth',2);
    temp_name = strcat('CS ',{' '}, name_CS(n,1), {' '}, vals{5}); 
    legend_caption{l,1} = temp_name{1,1}; 
    l = l+1; 
    %Plot the bottom 50% median 
    plot(x, legend_bottommed*ones(size(x)), ...
        ':','color','k','LineWidth',2);
    temp_name = strcat('CS ',{' '}, name_CS(n,1), {' '}, vals{6}); 
    legend_caption{l,1} = temp_name{1,1}; 
    l = l+1; 
    
    %Increate the count 
    k = k+1; 
    %Increase start and stop 
    p = p+1.5;
    
end 

%Change the axis limits 
xlim([0 p+5]); 
ylim([-5,ncs+5] ); 

%Create the legend 
legend(legend_caption); 

%Change the title 
title('Legend','FontSize', 14, 'FontWeight', 'bold'); 
    
%Save the legend 
legend_save = strcat(plot_names.savename, '_legend'); 
saveas(gcf, fullfile(plot_names.path, legend_save), 'pdf');
end 

