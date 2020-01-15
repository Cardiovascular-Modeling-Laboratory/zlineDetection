function [] = vid2Tiffs()
% Select video 
[file,path] = uigetfile('*.mp4','Select Video File'); 
% Select location to save images 
save_path = uigetdir(path,'Select Location to Save Video');
% Load video 
vid = VideoReader(fullfile(path,file));
% Get the total number of frames 
tot = vid.Duration.*vid.FrameRate; 
tot = floor(tot) - 1; 
% Get the name of the video
[~,~,e] = fileparts(file); 
vidname = strrep(file,e,'');  
for n = 1:tot
    frame = read(vid,n);
    frame_gray = rgb2gray(frame);
    
    % Pad number with leading zeros
    n_str = sprintf( '%03d', n ) ;
    % Save the frame 
    imwrite(frame_gray, fullfile(save_path,strcat(vidname,'_frame', ...
        n_str,'.tif')),'Compression','none');
end

end

