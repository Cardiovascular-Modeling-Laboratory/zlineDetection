function [ ] = actinExplorePlots( im_struct, actin_explore, settings )

%Get unique threshold values 
unique_thresh = unique(actin_explore.thresholds); 

%Get unique grid sizes
unique_grids = unique(actin_explore.grid_sizes); 
gtot = length(unique_grids); 

%Declare colors 
c = {'g','c','r','b','m','y'};

%Open a figure and hold on 
figure; 
hold on; 

%Loop through all of the grids 
for g= 1:gtot
    
    %Set up the grids to exclude 
    exclude_grid = zeros(size(actin_explore.grid_sizes)); 
    
    %Set the values that are not equal to the current grid size equal to
    %NaN. Otherwise, set the grid size to 1 
    exclude_grid(actin_explore.grid_sizes ~= unique_grids(g)) = NaN; 
    exclude_grid(~isnan(exclude_grid)) = 0; 
    
    % Get the included values 
    included_sums = actin_explore.sums + exclude_grid;
    included_sums(isnan(included_sums)) = []; 
    included_medians = actin_explore.medians + exclude_grid;
    included_medians(isnan(included_medians)) = [];
    included_actinthresh = actin_explore.thresholds + exclude_grid;
    included_actinthresh(isnan(included_actinthresh)) = [];
    included_nonzlinefrac = actin_explore.non_zlinefracs + exclude_grid; 
    included_nonzlinefrac(isnan(included_nonzlinefrac)) = [];
    included_zlinefrac = actin_explore.zlinefracs + exclude_grid; 
    included_zlinefrac(isnan(included_zlinefrac)) = [];
    
    %Plot the threshold vs. the median
    subplot(3,2,1); 
    hold on; 
    plot(included_actinthresh, included_medians, 'o', 'color', c{g}); 
    set(gca,'fontsize',12)
    title( strcat('Median (\mu m) vs Actin Threshold'),...
        'FontSize',12,'FontWeight','bold');
    ylabel('Median CZL (\mu m)','FontSize',12,...
        'FontWeight','bold');
    xlabel('Actin Threshold (dot product)','FontSize',12,'FontWeight','bold');

    %Plot the threshold vs. the sum
    subplot(3,2,2); 
    hold on; 
    plot(included_actinthresh, included_sums,'o', 'color', c{g}); 
    set(gca,'fontsize',12)
    title( strcat('Sum (\mu m) vs Actin Threshold'),...
        'FontSize',12,'FontWeight','bold');
    ylabel('Total CZL (\mu m)','FontSize',12,...
        'FontWeight','bold');
    xlabel('Actin Threshold (dot product)','FontSize',12,'FontWeight','bold');

    %Plot the non-zline fraction vs. actin trheshold 
    subplot(3,2,3); 
    hold on; 
    plot(included_actinthresh, included_nonzlinefrac,'o', 'color', c{g}); 
    set(gca,'fontsize',12)
    title( strcat('Non Z-line Fraction vs Actin Threshold'),...
        'FontSize',12,'FontWeight','bold');
    ylabel('Non Z-line Fraction','FontSize',12,...
        'FontWeight','bold');
    xlabel('Actin Threshold (dot product)','FontSize',12,'FontWeight','bold');

    %Plot the median vs non zline 
    subplot(3,2,4); 
    hold on; 
    plot(included_nonzlinefrac, included_medians,'o', 'color', c{g}); 
    set(gca,'fontsize',12)
    title( strcat('Median (\mu m) vs Non Z-line Fraction'),...
        'FontSize',12,'FontWeight','bold');
    ylabel('Median CZL (\mu m)','FontSize',12,...
        'FontWeight','bold');
    xlabel('Non Z-line Fraction','FontSize',12,'FontWeight','bold');

    %Plot the sum vs non zline 
    subplot(3,2,5); 
    hold on; 
    plot(included_nonzlinefrac, included_sums,'o', 'color', c{g}); 
    set(gca,'fontsize',12)
    title( strcat('Sum (\mu m) vs Non Z-line Fraction'),...
        'FontSize',12,'FontWeight','bold');
    ylabel('Total CZL (\mu m)','FontSize',12,...
        'FontWeight','bold');
    xlabel('Non Z-line Fraction','FontSize',12,'FontWeight','bold');
    
    %Plot the grid sizes in the correct color
    subplot(3,2,6); 
    hold on; 
    plot(unique_grids(g), 1, 'o', 'color', c{g}, ...
        'MarkerFaceColor', c{g}); 
    set(gca,'fontsize',12)
    title( strcat('Legend'),...
        'FontSize',12,'FontWeight','bold');

    xlabel('Grid Size (pixels)','FontSize',12,'FontWeight','bold');
    ylim([0 2])
    xlim([min(actin_explore.grid_sizes(:))-1 ...
        max(actin_explore.grid_sizes(:))+1])
    set(gca,'ytick',[])
end
    
    
%Save pdf
saveas(gcf, fullfile(im_struct.save_path, ...
    strcat(im_struct.im_name, '_ActinExplorationSummary')), 'pdf');
    
end

