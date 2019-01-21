function [ ] = actinExplorePlots( im_struct, summary_explore, actin_explore, settings )

if settings.actin_thresh > 1 && settings.grid_explore
    
    %Check how many grid conditions there are
    test = summary_explore.non_sarcs;
    cond = size(test,1); 
    
    %Open a figure and hold on 
    figure; 
    hold on; 
    
    %Define colors 
    c = {'g','c','r','b','m','y'}; 
    
    for k = 1:cond
        actin_thresh = summary_explore.actin_thresh{k,1}; 
        medians = summary_explore.medians{k,1}; 
        sums = summary_explore.sums{k,1}; 
        non_sarcs = summary_explore.non_sarcs{k,1};
        grid = summary_explore.grid_sizes(k,1); 
        
        %Plot the threshold vs. the median
        subplot(3,2,1); 
        hold on; 
        plot(actin_thresh, medians, 'o', 'color', c{k}); 
        set(gca,'fontsize',12)
        title( strcat('Median (\mu m) vs Actin Threshold'),...
            'FontSize',12,'FontWeight','bold');
        ylabel('Median CZL (\mu m)','FontSize',12,...
            'FontWeight','bold');
        xlabel('Actin Threshold (dot product)','FontSize',12,'FontWeight','bold');

        %Plot the threshold vs. the sum
        subplot(3,2,2); 
        hold on; 
        plot(actin_thresh, sums,'o', 'color', c{k}); 
        set(gca,'fontsize',12)
        title( strcat('Sum (\mu m) vs Actin Threshold'),...
            'FontSize',12,'FontWeight','bold');
        ylabel('Total CZL (\mu m)','FontSize',12,...
            'FontWeight','bold');
        xlabel('Actin Threshold (dot product)','FontSize',12,'FontWeight','bold');

        %Plot the non-zline fraction vs. actin trheshold 
        subplot(3,2,3); 
        hold on; 
        plot(actin_thresh, non_sarcs,'o', 'color', c{k}); 
        set(gca,'fontsize',12)
        title( strcat('Non Z-line Fraction vs Actin Threshold'),...
            'FontSize',12,'FontWeight','bold');
        ylabel('Non Z-line Fraction','FontSize',12,...
            'FontWeight','bold');
        xlabel('Actin Threshold (dot product)','FontSize',12,'FontWeight','bold');

        %Plot the median vs non zline 
        subplot(3,2,4); 
        hold on; 
        plot(non_sarcs, medians,'o', 'color', c{k}); 
        set(gca,'fontsize',12)
        title( strcat('Median (\mu m) vs Non Z-line Fraction'),...
            'FontSize',12,'FontWeight','bold');
        ylabel('Median CZL (\mu m)','FontSize',12,...
            'FontWeight','bold');
        xlabel('Non Z-line Fraction','FontSize',12,'FontWeight','bold');

        %Plot the sum vs non zline 
        subplot(3,2,5); 
        hold on; 
        plot(non_sarcs, sums,'o', 'color', c{k}); 
        set(gca,'fontsize',12)
        title( strcat('Sum (\mu m) vs Non Z-line Fraction'),...
            'FontSize',12,'FontWeight','bold');
        ylabel('Total CZL (\mu m)','FontSize',12,...
            'FontWeight','bold');
        xlabel('Non Z-line Fraction','FontSize',12,'FontWeight','bold');
        
        
        %Plot the grid sizes in the correct color
        subplot(3,2,6); 
        hold on; 
        plot(grid, 1, 'o', 'color', c{k},  'MarkerFaceColor', c{k}); 
        set(gca,'fontsize',12)
        title( strcat('Simple Legend'),...
            'FontSize',12,'FontWeight','bold');
%         ylabel('Grid Size (pixels)','FontSize',12,...
%             'FontWeight','bold');
        xlabel('Grid Size (pixels)','FontSize',12,'FontWeight','bold');
        ylim([0 2])
        xlim([min(summary_explore.grid_sizes(:))-1 ...
            max(summary_explore.grid_sizes(:))+1])
        set(gca,'ytick',[])
    end
    
    %Change last plot 
    
    %Save pdf
    saveas(gcf, fullfile(im_struct.save_path, ...
        strcat(im_struct.im_name, '_ActinExplorationSummary')), 'pdf');
        
end
    
end

