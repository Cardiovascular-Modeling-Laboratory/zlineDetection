% changePlotAppearance - Change the settings of the plot, including the
% title, axes, and axis labels. Written for usage with accompanying
% plotting functions.
%
% Usage: 
%   changePlotAppearance( plot_settings )
%
% Arguments:
%   plot_settings   - Struct containing plotting settings. See 
%                       defaultPlotSettings.m for more information.
%
% Dependencies: 
%   MATLAB Version >= 9.5 
%
% Tessa Altair Morris
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [ ] = changePlotAppearance( plot_settings )

% Make sure of the plot settings have been defined or declared. 
plot_settings = defaultPlotSettings( plot_settings );

%%%%%%%%%%%%%%%%%%%%%%%%%% axis limits %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Change the limits of the xaxis 
if plot_settings.changeXlimits 
    xlim( [ plot_settings.xmin, plot_settings.xmax ] ); 
end 

% Change the limits of the xaxis 
if plot_settings.changeYlimits 
    ylim( [ plot_settings.ymin, plot_settings.ymax ] ); 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%% x-ticks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Change the x ticks 
if plot_settings.setXticks
    set(gca,'XTick',plot_settings.xtick);
end 

% Change the x tick labels 
if plot_settings.changeXticklabel
    set(gca,'XTickLabel',plot_settings.xticklabel);
end 

% Change the rotation of the x-ticks 
if plot_settings.changeXtickRotation
    set(gca,'XTickLabelRotation', plot_settings.xtickrotation ); 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%% y-ticks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Change the y ticks 
if plot_settings.setYticks
    set(gca,'YTick',plot_settings.ytick);
end 
 
% Change the y tick labels 
if plot_settings.changeYticklabel
    set(gca,'YTick',plot_settings.yticklabel);
end 
 
% Change the rotation of the y-ticks 
if plot_settings.changeYtickRotation
    set(gca,'YTickLabelRotation', plot_settings.ytickrotation ); 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%% font sizes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Change the font size
set(gca, 'fontsize', plot_settings.font_size, 'FontWeight', 'bold');

% Change the size of the x ticks 
if plot_settings.changeXtickfont
    set(gca,'XTickLabel', 'fontsize', plot_settings.xtickfontsize, ...
        'Color','k'); 
end

% Change the size of the y ticks 
if plot_settings.changeYtickfont
    set(gca,'YTickLabel', 'fontsize', plot_settings.ytickfontsize, ...
        'Color','k');  
end

%%%%%%%%%%%%%%%%%%%% axis labels and titles %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Change the x labels 
if plot_settings.addXaxislabel
    xlabel(plot_settings.xlabel,'FontSize', plot_settings.xlabelsize, ...
        'FontWeight', 'bold','Color', 'k');
end 
% Change the y label
if plot_settings.addYaxislabel
    ylabel(plot_settings.ylabel,'FontSize', plot_settings.ylabelsize, ...
        'FontWeight', 'bold','Color', 'k');
end 

% Change the title 
if plot_settings.addTitle
    title(plot_settings.title, 'FontSize', plot_settings.titlesize, ...
        'FontWeight', 'bold','Color', 'k');
end 


end

