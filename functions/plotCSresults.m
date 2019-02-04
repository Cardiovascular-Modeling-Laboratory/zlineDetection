function [] = plotCSresults( CS_explorevalues, medians,CS_median, n,...
    names)
%Plot CS summaries

% %Get the number of unique grid sizes
% gn = unique(CS_explorevalues(:,1)); 
% %Get the number of unique actin filter sizes 
% afn = unique(CS_explorevalues(:,2)); 
% 
% %Color options 
% colors = {[1,0.6,1], [0.2,0.6,1], [0.6275,0.6275,0.6275], 'r','g'};
% 
% %Get positions 
% p = 0;
% g = 1; 
% 
% %Get middle x value 
% filter_x = zeros(size(afn,1),1);
% f = 1; 
% 
% %Plot the data 
% figure; 
% hold on; 
% 
% for k = 1:length(afn)*length(gn)
% 
%     %Get the start and end positions of the condition 
%     pa = 1 + (k - 1)*n; 
%     po = k*n;
% 
%     %Get the middle value
%     x0 = (2*p+1)/2; 
% 
%     %Compute the x-axis
%     x = p:p+1; 
%     if ~isempty(medians)
%         
%         %Calculate the median czl 
%         median_values = medians(pa:po,1); 
% 
%         %Get the mean median values 
%         mean_med = mean(median_values); 
%         std_med = std(median_values); 
%     
%         %Plot all of the points 
%         plot(x0*ones(size(median_values,1)),median_values,'.',...
%             'MarkerSize', 8, ...
%             'MarkerEdgeColor',colors{g},...
%             'MarkerFaceColor',colors{g});
% 
%         %Plot the mean of the medians
%         plot(x,mean_med*ones(size(x)), '-','color',colors{g},'LineWidth',2);
% 
%         %Plot range of orientation values 
%         fill([p, p+1, p+1, p], ...
%             [mean_med-std_med, mean_med-std_med, ...
%             mean_med+std_med, mean_med+std_med], ...
%             colors{g}, 'FaceAlpha', 0.3,'linestyle','none');
%         
%         %Make the color of the cs total equal to back 
%         cs_color = 'k'; 
%     else
%         cs_color = colors{g}; 
%     end 
%    
% 
%     %Plot the median 
%     y = CS_median(k,1)*ones(size(x)); 
%     plot(x,y, '-','color',cs_color,'LineWidth',2);
% 
%     %Increase start and stop 
%     p = p+1.5;
%     if mod(k, length(gn)) == 0 
%         p = p+1; 
%     end 
% 
%     %Increate the grid value 
%     if g == 1
%         g = g+1;
%     elseif g == 2
%         filter_x(f,1) = x0; 
%         f = f+1; 
%         g = g+1;
%     else
%         g = 1; 
%     end 
% 
% end 
% 
% if ~isempty(medians)
%     buffer = 0.3*min(medians(:)); 
%     if buffer < 0.1
%         buffer = 0.1; 
%     end 
% 
%     %Get the minimum and max median values 
%     ymin = min(medians(:)) - buffer; 
%     ymax = max(medians(:)) + buffer; 
% else
%    buffer = 0.3*min(CS_median(:)); 
%     if buffer < 0.1
%         buffer = 0.1; 
%     end 
%     
%     ymin = min(CS_median(:)) - buffer; 
%     ymax = max(CS_median(:)) + buffer; 
% end 
% 
% 
% %Change axis labels
% ylim([ymin ymax])
% xlim([-2 p+1])
% set(gca,'XTick',filter_x) 
% set(gca,'XTickLabel',num2cell(afn))
% set(gca, 'fontsize',12,'FontWeight', 'bold');
% xlabel(names.x,'FontSize', 14, 'FontWeight', 'bold');
% ylabel(names.y,'FontSize',...
%     14, 'FontWeight', 'bold');
% title(names.title,...
%     'FontSize', 14, 'FontWeight', 'bold')
% 
% saveas(gcf, fullfile(names.path, names.savename), 'pdf');

end
