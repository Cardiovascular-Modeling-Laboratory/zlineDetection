
% Add subdirectories to path 
addpath('coherencefilter_version5b');
addpath('continuous_zline_detection');

% Prompt the user to select the images they would like to analyze. 
[ image_files, image_path, n ] = ...
    load_files( {'*.TIF';'*.tif';'*.*'} ); 

% Save filename 
filename = strcat(image_path{1}, image_files{1,1});
    
% Variable parameters 
%settings.orientsmoothsigma - gaussian smoothing before calculation of the 
%image Hessian
var_sigma = 0.25:0.25:1; 
%Sigma of the Gaussian smoothing of the Hessian.
var_rho = 0.5:0.25:4;
% Total Diffusion Time 
var_diffusiontime = [1,3,5,8,10,12,15,20,25,50,100,200]; 

%%%%%%%%%%%%%%%%%%%%% Set nonvariable parameters %%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize structural arrays. 
settings = struct(); 
Options = struct();

% Pixel to micron conversion
settings.pix2um = 6.22; pix2um = 6.22; 
% Radius of the flat disk-shaped structuring element used for the top hat
% filter
settings.bio_tophat_size = 0.5; 
settings.tophat_size = round( settings.bio_tophat_size.*pix2um ); 
% Size of small objects to be removed using bwareopen
settings.bio_noise_area = 0.2;
settings.noise_area= round( settings.bio_noise_area.*(pix2um.^2) ); 
% Save the minimum branch size to be included in analysis 
settings.bio_branch_size = 0.6; 
settings.branch_size = round( settings.bio_branch_size.*pix2um ); 

% Display figures
settings.disp_df = false; 
settings.disp_tophat = false; 
settings.disp_bw = false;
settings.disp_nonoise = false; 
settings.disp_skel = false;

% Calculate continuous z-line length 
settings.tf_CZL = true; 
settings.dp_threshold = 0.99; 

% Calculate OOP
settings.tf_OOP = false; 
settings.cardio_type = true; 

% PRESET VALUE. Set the diffusion time stepsize 
Options.dt = 0.15;

% PRESET VALUE. Set the numerical diffusion scheme that the program should 
% use. This will be set to 'I', Implicit Discretization (only works in 2D)
Options.Scheme = 'I';

% PRESET VALUE. Use Weickerts equation (plane like kernel) to make the 
% diffusion tensor. 
Options.eigenmode = 0;

% PRESET VALUE. Constant that determines the amplitude of the diffusion  in 
% smoothing Weickert equation
Options.C = 1E-10; 

%%%%%%%%%%%%%%%%% Loop through parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the number of variable parameters 
sn = length(var_sigma); 
pn = length(var_rho); 
dtn = length(var_diffusiontime); 

%Total number of iterations 
tot = sn*pn*dtn; 

%Store iteration number 
it = 1; 

%Create a cell to store all distances, medians, and parameters 
all_lengths = cell(1,tot); 
all_medians = cell(1,tot); 
all_diffusiontimes = cell(1,tot); 
all_sigma = cell(1,tot); 
all_rho =  cell(1,tot);

%Save a summary file for the continuous z-line lengths 
%Get today's date in string form.
date_format = 'yyyy_mm_dd';
today_date = datestr(now,date_format);

%Create a summary file name 
summary_file_name = strcat(today_date, '_zline_summary.mat');

%Save and create a summary file
save(fullfile(image_path{1}, summary_file_name), ...
    'all_lengths', 'all_medians', 'all_diffusiontimes',...
    'all_sigma', 'all_rho');
            
         
%Loop trhough sigma values
for s = 1:sn
    
    %Set the sigma 
    Options.sigma = var_sigma(s); 
    %Set biological sigma value 
    settings.bio_sigma = var_sigma(s)./pix2um; 
    
%Loop through rho values
    for p = 1:pn
        
        %Set the rho
        Options.rho = var_rho(p); 
        %Set biological rho 
        settings.bio_rho = var_rho(p)./pix2um; 
        
%Loop through diffusion time 
        for t = 1:dtn
            
            %Set the diffusion time 
            Options.T = var_diffusiontime(t); 
            
            % Save the Options in the settings struct. 
            settings.Options = Options;

            % Increase iteration number 
            it = it +1;
            
            % Save variables as strings 
            s_string = num2str(var_sigma(s)); 
            p_string = num2str(var_rho(p)); 
            dt_string = num2str(var_diffusiontime(t)); 

            % Replace '.' with 'p' for decimals
            s_string = strrep(s_string, '.', 'p'); 
            p_string = strrep(p_string, '.', 'p'); 
            
            %Save current parameters 
            all_diffusiontimes{1,it} = var_diffusiontime(t); 
            all_sigma{1,it} = var_sigma(s); 
            all_rho{1,it} =  var_rho(p);

            % Save the name of the file & folder
            save_name = strcat('D', dt_string, '_sigma', s_string, ...
                '_rho', p_string); 

            % Perform the analysis including saving the image 
            im_struct = ...
                parameterExploreAnalyzeImage( filename, settings, ...
                save_name ); 
            
            %Calculate the continuous z-line length
            all_lengths{1,it} = continuous_zline_detection(im_struct, ...
                settings); 
        
            %Compute the median
            all_medians{1,it} = median( all_lengths{1,it} ); 
        
            %Create a histogram of the distances
            figure; histogram(all_lengths{1,it});
            set(gca,'fontsize',16)
            hist_name = strcat('Median: ', num2str(all_medians{1,it}),...
                ' \mu m');
            title(hist_name,'FontSize',18,'FontWeight','bold');
            xlabel('Continuous Z-line Lengths (\mu m)','FontSize',18,...
                'FontWeight','bold');
            ylabel('Frequency','FontSize',18,'FontWeight','bold');
        
            %Save histogram as a tiff 
            fig_name = strcat( save_name, '_CZLhistogram');
            saveas(gcf, fullfile(im_struct.save_path, fig_name), 'tiffn');

            %Append the summary file 
            save(fullfile(image_path{1}, summary_file_name), ... 
                'all_lengths', 'all_medians', '-append');

            %Close all of the images 
            close all; 

        end 
    end 
end 



% Loop through all of the image files 
for k = 1:n 
    % Store the current filename 
    filename = strcat(image_path{1}, image_files{1,k});
    
    % Perform the analysis including saving the image 
    im_struct = analyzeImage( filename, settings ); 
    
    % If the user wants to calculate continuous z-line length 
    if settings.tf_CZL 

        if k == 1
            %Create a cell to store all distances 
            all_lengths = cell(1,n); 
            all_medians = cell(1,n); 
            
            %If there is more than one image being analyzed, create a summary
            %file 
            if n > 1
                %Get today's date in string form.
                date_format = 'yyyy_mm_dd';
                today_date = datestr(now,date_format);

                %Create a summary file name 
                summary_file_name = strcat(today_date, ...
                    '_zline_summary.mat');

                %Save and create a summary file
                save(fullfile(image_path{1}, summary_file_name), ...
                    'all_lengths', 'all_medians', 'image_files');
            end 
        end 
        
        %Calculate the continuous z-line length 
        all_lengths{1,k} = continuous_zline_detection(im_struct, settings); 
        
        %Compute the median
        all_medians{1,k} = median( all_lengths{1,k} ); 
        
        %Create a histogram of the distances
        figure; histogram(all_lengths{1,k});
        set(gca,'fontsize',16)
        hist_name = strcat('Median: ', num2str(all_medians{1,k}),' \mu m');
        title(hist_name,'FontSize',18,'FontWeight','bold');
        xlabel('Continuous Z-line Lengths (\mu m)','FontSize',18,...
            'FontWeight','bold');
        ylabel('Frequency','FontSize',18,'FontWeight','bold');
        
        %Save histogram as a tiff 
        fig_name = strcat( im_struct.im_name, '_CZLhistogram');
        saveas(gcf, fullfile(im_struct.save_path, fig_name), 'tiffn');
        
        %If there is more than one FOV, save a summary file
        if n > 1 
            %Append the summary file 
            save(fullfile(image_path{1}, summary_file_name), ... 
                'all_lengths','all_medians','all_diffusiontimes',... 
                'all_sigma', 'all_rho''-append');
        end 
        
        %Close all of the images 
        close all; 
        
    end 

    % If the user wants to calculate OOP
    if settings.tf_OOP && k == 1
        disp('NOT YET IMPLEMENTED: OOP'); 
        %settings.cardio_type
    end 
    
    % Close all figures
    close all; 
    
    % Clear the file name 
    clear filename
   
end 


