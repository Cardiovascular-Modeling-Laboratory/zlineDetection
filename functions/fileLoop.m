function [  ] = fileLoop(  )
%This function will take file names as an input and then loop through them,
%calling the analyze function


% Inside the for loop give the option to calculate the continuous z-line
% length

% If the user wants to calculate OOP for the whole directory, append the
% orientation vectors

end

% 
% function xl = runDir(dirPath,settings)
% 
% % varargin{1} is: 0 if just get images, 1 if get mobilities
% 
% imdir = CompileImgs(dirPath);
% 
% % S = zeros(length(imdir),1);
% 
% xl = cell(length(imdir)+1,8);
% 
% xl{1,1} = 'Image Name';
% xl{1,2} = 'Final S2D';
% xl{1,3} = 'Average Orientation (degrees)';
% xl{1,4} = 'Sfull fit';
% xl{1,5} = 'Correlation Length (nm)';
% xl{1,6} = 'OD Bin Angles (deg.)';
% xl{1,7} = 'OD Bin Counts (pixels)';
% xl{1,8} = 'Frame Sizes (µm)';
% xl{1,9} = 'S2D for each Frame Size';
% xl{1,10} = 'Model Fit for each Frame Size';
% 
% hwaitdir = waitbar(0,'Running Directory...');
% numIms = length(imdir);
% 
% for i = 1:numIms
%     waitbar(i/numIms,hwaitdir,['Processing ', imdir(i).name]);
% %     disp(imdir(i).name)
%     imfilei = imdir(i).path;
%     [xl{i+1,2}, xl{i+1,3}, xl{i+1,6}, xl{i+1,7}, xl{i+1,8}, xl{i+1,9}, xl{i+1,10}, BETA] = getS2Dauto(imfilei,settings);
%     xl{i+1,4} = BETA(1);
%     xl{i+1,5} = BETA(2)*1000;
%     xl{i+1,1} = imdir(i).name;
% end
% 
% close(hwaitdir)
% 
% end

% This should essentially do what Compile images did 
% function out = CompileImgs(FolderPath)
% disp(FolderPath)
% 
% ad = pwd;
% 
% % First compile any images from the folderpath
% cd(FolderPath)
% 
% PNG = dir('*.png');
% JPG = dir('*.jpg');
% JPEG = dir('*.jpeg');
% TIF = dir('*.tif');
% TIFF = dir('*.tiff');
% BMP = dir('*.bmp');
% CurIms = [PNG; JPG; JPEG; TIF; TIFF; BMP]; % Generate directory structure of images in FolderPath
% cd(ad)
% 
% for p = 1:length(CurIms)
%     CurIms(p).path = [FolderPath, CurIms(p).name];   % prepend the folder path to the image names
% end
% 
% % Remove any ghost files with the ._ prefix
% c=1;
% pp=1;
% while pp<=length(CurIms)
%     if ~strcmp(CurIms(pp).name(1:2),'._')
%         out(c) = CurIms(pp);
%         c = c+1;
%     end
%     pp = pp+1;
% end
% end
