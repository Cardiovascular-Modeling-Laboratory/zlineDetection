function [ condition_values, mean_condition,std_condition ] =...
    plotConditions(data_points, descriptors, cond_names,...
    grid_sizes, actin_threshs, plot_names)

%Get the number of unique grid sizes
if ~isempty(grid_sizes)
    unique_grids = unique(grid_sizes); 
    gn = length(unique_grids); 
else
    gn = 1; 
end

%Get the number of unique actin filter sizes 
if ~isempty(actin_threshs)
    unique_thresh = unique(actin_threshs); 
    afn = length(unique_thresh); 
else
    afn = 1; 
end 

%Save the number of condition names 
n_cond = length(cond_names); 

%Condition_values 
condition_values = cell(n_cond*gn*afn,1); 
mean_condition = zeros(n_cond*gn*afn,1);
std_condition = zeros(n_cond*gn*afn,1); 

%Open a figure
figure; 
hold on; 

%Get middle x value 
filter_x = zeros(size(afn));
f = 1; 

%Colors
colors = {[1,0.6,1], [0.2,0.6,1], [0.6275,0.6275,0.6275], 'r','g'};

%Start color counts 
c = 1; 

%Start counts
k = 1; 

for g= 1:gn
    
    % Set up the grids to exclude 
    exclude_grid = zeros(size(grid_sizes)); 
    
    %Only open suplots if there is more than one grid
    if gn > 1
        subplot(gn,1,g); 
        hold on; 
        %Set the values that are not equal to the current grid size equal to
        %NaN. Otherwise, set the grid size to 1 
        exclude_grid(grid_sizes ~= gn(g)) = NaN; 
        exclude_grid(~isnan(exclude_grid)) = 1; 
    
    end 
    
    %Set position equal to 0 
    p = 0; 
    
    for a = 1:afn
        % Set up the thresholds to exclude 
         exlude_thresh = zeros(size(actin_threshs)); 
            
        if afn > 1
            %Set the values that are not equal to the current threshold
            %size equal to NaN. Otherwise, set the grid size to 1 
            exlude_thresh(actin_threshs ~= afn(a)) = NaN; 
            exlude_thresh(~isnan(exlude_thresh)) = 1; 

        end 
        
        %On the first iteration, set the legend
        if a == 1
            legend(cond_names); 
            set(gca, 'fontsize',12,'FontWeight', 'bold');
        end 
        %Add the exclusion threshold and grids
        exlude_exploration = exclude_grid+exlude_thresh; 
        
        %Repeat this matrix to make it the size of the 
        exlude_exploration = repmat(exlude_exploration, ...
            [1, size(data_points,2)]); 
        
        %Loop through all of the conditions 
        for n = 1:n_cond
            
            %Get the middle value
            x0 = (2*p+1)/2; 

            %Compute the x-axis
            x = p:p+1; 
           
            %Values to exclude
            exclude_vals = zeros(size(descriptors)); 
            exclude_vals(descriptors ~= n) = NaN; 
            %Transpose
            exclude_vals = exclude_vals';
            %Repeat the values to make the same size as the data matrix  
            exclude_vals = repmat(exclude_vals, [size(data_points,1), 1]);
            
            %Add exlusions 
            exclusions = exlude_exploration + exclude_vals; 
            %Make sure that all of values that are non NaN are 0 
            exclusions(~isnan(exclusions)) = 0; 
            
            %Add the values plus the points to exclude 
            include_vals = data_points + exclusions; 
    
            %Reshape and remove NaN values
            include_vals = include_vals(:);
            include_vals(isnan(include_vals)) = []; 

            %Save data 
            condition_values{k,1} =include_vals; 
            mean_condition(k,1) = mean(include_vals); 
            std_condition(k,1) = std(include_vals); 

            %Plot all of the points 
            plot(x0*ones(size(condition_values{k,1})),...
                condition_values{k,1},'.',...
                'MarkerSize', 8, ...
                'MarkerEdgeColor',colors{c},...
                'MarkerFaceColor',colors{c});

            %Plot the mean 
            plot(x, mean_condition(k,1)*ones(size(x)), ...
                '-','color',colors{c},'LineWidth',2);

            %Plot range of orientation values 
            hold on; 
            fill([p, p+1, p+1, p], ...
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
    
            %Increate the count 
            k = k+1; 
            %Increase start and stop 
            p = p+1.5;
            
            if g== 1 && n == round(n_cond/2); 
                filter_x(f,1) = x0; 
                f = f+1; 
            end 
            
            if n == n_cond
                p = p+1; 
            end 
    
        end
        
    end
end

%Set the axis limits for the y axis 
buffer = 0.3*min(data_points(:)); 
if buffer < 0.1
    buffer = 0.1; 
end 

%Get the minimum and max median values 
ymin = min(data_points(:)) - buffer; 
ymax = max(data_points(:)) + buffer; 

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
    set(gca,'XTickLabel',num2cell(afn))

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

    
end 
