% defaultPlotSettings - Sets the default settings for a plot and checks to
% make sure that the provided settings are correct. Written for usage with
% accompanying plotting functions. 
%
% Usage: 
%   plot_settings = defaultPlotSettings( plot_settings );
%
% Arguments:
%   plot_settings   - structural array that contains plotting descriptions.
%                       See PlotSettingsDescriptions.pdf for a detailed
%                       description of fields. 
%                       Class Support: STRUCT
% Returns:
%   plot_settings   - structural array that contains plotting descriptions
%                       with the default settings added to the user defined
%                       descriptions. 
%                       See PlotSettingsDescriptions.pdf for a detailed
%                       description of fields. 
%                       Class Support: STRUCT
%
% Dependencies: 
%   MATLAB Version >= 9.5 
%
% Tessa Altair Morris
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [ plot_settings ] = defaultPlotSettings( plot_settings )

%%%%%%%%%%%%%%%%%% Markers, Line, and Box Settings %%%%%%%%%%%%%%%%%%%%%%%%
% Defaults: 
default_marker = {'o'};     % Marker Type
default_markersize = 10;    % Marker Size
default_linewidth = 1;      % Line Width
default_linetype = {'-'};   % Line Type 
default_color = {'k'};      % Default Color 
default_binnum = 20;        % Number of bins for dot plot 
default_sp = 0.2;          % Spacing of standard deviation bars
default_boxwidth = 0.9;     % Width of the boxes 
default_transparencybox = 0.3;	% Transparency of box plots
default_transparencybar = 1;    % Transparency of bar plots 

% Set the overall color is not defined 
if ~isfield(plot_settings, 'colors')
    plot_settings.colors = default_color; 
end

%>>>>> Specific Plotting: Box plot 
% Determine if this is a box plot by determining if the type of boxplot is
% defined. 
if ~isfield(plot_settings, 'typeMean')
    plot_settings.isBox = false; 
    plot_settings.typeMean = false; 
else
    plot_settings.isBox = true; 
end 

%>>>>> Markers 
% Marker Type 
if ~isfield(plot_settings, 'marks')
    plot_settings.marks = default_marker; 
else
    % Check to make sure the marker is a string with a cell 
    if isstring(plot_settings.marks)
        plot_settings.marks = {plot_settings.marks}; 
    end 
end
% Marker Size 
if ~isfield(plot_settings, 'markersize')
    plot_settings.markersize = default_markersize; 
end
% Color of the marker edge
if ~isfield(plot_settings, 'markercoloredge')
    plot_settings.markercoloredge = plot_settings.colors; 
end
% Color of the marker fill 
if ~isfield(plot_settings, 'markercolorfill')
    plot_settings.markercolorfill = plot_settings.colors; 
end

%>>>>> Lines 
% Line Width 
if ~isfield(plot_settings, 'linewidth')
    if ~plot_settings.typeMean && plot_settings.isBox
        plot_settings.linewidth = 3; 
    else
        plot_settings.linewidth = default_linewidth; 
    end 
    
end 
% Line Type
if ~isfield(plot_settings, 'linetype')
    if ~plot_settings.typeMean && plot_settings.isBox
        plot_settings.linetype = {'--'}; 
    else
        plot_settings.linetype = default_linetype; 
    end 
end 

% Color of the lines
if ~isfield(plot_settings, 'linecolor')
    plot_settings.linecolor = plot_settings.colors; 
end


%>>>>> Fill  
% Color of the fill
if ~isfield(plot_settings, 'colorfill')
    if ~plot_settings.typeMean && plot_settings.isBox
        plot_settings.colorfill = {'w'}; 
    else
        plot_settings.colorfill = plot_settings.colors; 
    end 
end 
% Fill transparency
if ~isfield(plot_settings,'filltransparency')
    if plot_settings.isBox 
        plot_settings.filltransparency = default_transparencybox;
    else
        plot_settings.filltransparency = default_transparencybar;
    end 
end 
% Border color 
if ~isfield(plot_settings,'bordercolor')
    plot_settings.bordercolor = default_color;
end 
% Border type
if ~isfield(plot_settings,'bordertype')
    if ~plot_settings.typeMean
        plot_settings.bordertype = default_linetype;
    else
        plot_settings.bordertype = {'None'};
    end 
end 
% Border Width
if ~isfield(plot_settings,'borderwidth')
    plot_settings.borderwidth = default_linewidth;
end 

%>>>>> Specific Plotting: Dot plot 
% Number of bins 
if ~isfield(plot_settings, 'num_bins')
    plot_settings.num_bins = default_binnum; 
end 

%>>>>> Specific Plotting: Standard Deviation Bars
% Set the spacing of the standard deviation bars
if ~isfield(plot_settings, 'sp')
    plot_settings.sp = default_sp;
end 

%>>>>> Specific Plotting: Box and Bar plots
if ~isfield(plot_settings,'box_width')
    plot_settings.box_width = default_boxwidth; 
end 

%%%%%%%%%%%%%%%%%%%%%% Formatting the Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Default font sizes for the axes and label
default_fontsize = 12; 
default_axisfontsize = 14; 

% If it is not a field, set it to be the default. 
if ~isfield(plot_settings, 'font_size')
    plot_settings.font_size = default_fontsize; 
end

% Check if the x ticks are set to anything.  
if ~isfield(plot_settings, 'xtick')
    plot_settings.setXticks = false; 
else
    plot_settings.setXticks = true; 
end

% Check if the x tick labels are changed, must also declare where the
% x-ticks are located. If it has the same number of points then it can be
% declared. 
if ~isfield(plot_settings, 'xticklabel')
    plot_settings.changeXticklabel = false; 
else
    % Set the change label to false unless the x ticks have also been
    % changed and they are the smae length
    plot_settings.changeXticklabel = false; 
    if isfield(plot_settings, 'xtick') 
        if length(plot_settings.xticklabel) == length(plot_settings.xtick)
            plot_settings.changeXticklabel = true;        
        end 
    end 
    
end

% Check if the x tick rotation is changed 
if ~isfield(plot_settings, 'xtickrotation')
    plot_settings.changeXtickRotation = false; 
else
    plot_settings.changeXtickRotation = true; 
end

% Check if the x tick font size is changed
if ~isfield(plot_settings, 'xtickfontsize')
    plot_settings.changeXtickfont = false; 
else
    plot_settings.changeXtickfont = true; 
end

% Check if the y ticks are set to anything.  
if ~isfield(plot_settings, 'ytick')
    plot_settings.setYticks = false; 
else
    plot_settings.setYticks = true; 
end
 
% Check if the y tick labels are changed, must also declare where the
% y-ticks are located. If it has the same number of points then it can be
% declared. 
if ~isfield(plot_settings, 'yticklabel')
    plot_settings.changeYticklabel = false; 
else
    % Set the change label to false unless the x ticks have also been
    % changed and they are the smae length
    plot_settings.changeYticklabel = false; 
    if isfield(plot_settings, 'ytick')
        if length(plot_settings.yticklabel) == length(plot_settings.ytick)
            plot_settings.changeYticklabel = true;        
        end 
    end 
end
 
% Check if the y tick rotation is changed 
if ~isfield(plot_settings, 'ytickrotation')
    plot_settings.changeYtickRotation = false; 
else
    plot_settings.changeYtickRotation = true; 
end

% Check if the y tick font size is changed
if ~isfield(plot_settings, 'ytickfontsize')
    plot_settings.changeYtickfont = false; 
else
    plot_settings.changeYtickfont = true; 
end

% Check to see if there is a provided title and if so whether its font size
% is set 
if ~isfield(plot_settings, 'title')
    plot_settings.addTitle = false; 
else
    plot_settings.addTitle = true; 
    % Set the font size if it has not already been set
    if ~isfield(plot_settings, 'titlesize')
        plot_settings.titlesize = default_axisfontsize; 
    end 
end

% Check to see if there is a provided x-axis label and if so whether its 
% font size is set 
if ~isfield(plot_settings, 'xlabel')
    plot_settings.addXaxislabel = false; 
else
    plot_settings.addXaxislabel = true; 
    % Set the font size if it has not already been set
    if ~isfield(plot_settings, 'xlabelsize')
        plot_settings.xlabelsize = default_axisfontsize; 
    end 
end

% Check to see if there is a provided y-axis label and if so whether its 
% font size is set 
if ~isfield(plot_settings, 'ylabel')
    plot_settings.addYaxislabel = false; 
else
    plot_settings.addYaxislabel = true; 
    % Set the font size if it has not already been set
    if ~isfield(plot_settings, 'ylabelsize')
        plot_settings.ylabelsize = default_axisfontsize; 
    end 
end

% Change the x-axis limits 
if isfield(plot_settings, 'xmin') && isfield(plot_settings, 'xmax') 
    plot_settings.changeXlimits = true; 
else
    plot_settings.changeXlimits = false; 
end 

% Change the y-axis limits 
if isfield(plot_settings, 'ymin') && isfield(plot_settings, 'ymax') 
    plot_settings.changeYlimits = true; 
else
    plot_settings.changeYlimits = false; 
end 
end

