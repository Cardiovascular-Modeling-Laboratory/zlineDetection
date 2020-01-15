%% Select data 
% Select the single cell summary file
[file,path] = uigetfile('*SC_Summary*.mat','Select the single cell summary file...'); 
% Select the location to save results.
save_path = uigetdir(path,'Select Location to Save Plots...');

%% Load data
data = load(fullfile(path,file)); 
SC_results = data.SC_results; 

%% Store frame numbers 
n_im = length(SC_results.zline_images)-1; 
% Get the frame numbers
frame_num = zeros(1,n_im);
% Initialize matrices to store metrics  
zlineOOP = zeros(1,n_im);
CZL_medians = zeros(1,n_im);
for k = 1:n_im
    % Get frame number
    name = SC_results.zline_images{1,k}; 
    indx = strfind(name,'_frame');
    temp = name(indx:end); 
    temp1 = strrep(temp,'_frame',''); 
    temp2 = strrep(temp1,'.tif',''); 
    frame_num(1,k) = str2double(temp2); 
    
    zlineOOP(1,k) = SC_results.OOPs{1,k}; 
    CZL_medians(1,k) = SC_results.medians{1,k}; 
end 

%% Plot z-line OOP
figure; 
plot(frame_num, zlineOOP,'-ko',...
    'LineWidth',2,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','k',...
    'MarkerSize',8); 
set(gca, 'fontsize',12,'FontWeight', 'bold');
xlabel('Frame Number','FontSize',...
    14, 'FontWeight', 'bold');
ylabel('Z-line Orientational Order','FontSize',...
    14, 'FontWeight', 'bold');
ylim([0,1]); 

saveas(gcf, fullfile(save_path,'zlineOOP.pdf'));

%%
figure; 
plot(frame_num, CZL_medians,'-ko',...
    'LineWidth',2,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','k',...
    'MarkerSize',8); 
set(gca, 'fontsize',12,'FontWeight', 'bold');
xlabel('Frame Number','FontSize',...
    14, 'FontWeight', 'bold');
ylabel('Median Cont. Z-line Length (\mu m)','FontSize',...
    14, 'FontWeight', 'bold');
saveas(gcf, fullfile(save_path,'medianCZL.pdf'));

%%

figure; 
plot(frame_num, CZL_medians,'-ko',...
    'LineWidth',2,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','k',...
    'MarkerSize',8); 
set(gca, 'fontsize',12,'FontWeight', 'bold');
xlabel('Frame Number','FontSize',...
    14, 'FontWeight', 'bold');
ylabel('Median Cont. Z-line Length (\mu m)','FontSize',...
    14, 'FontWeight', 'bold');
saveas(gcf, fullfile(save_path,'medianCZLpix.pdf'));

