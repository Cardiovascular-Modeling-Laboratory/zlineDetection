function [] = addExperimentalTestCase(im_struct, r, expcasename, expcasepath)
% If the experimental test case .mat file exists add to it, otherwise
% create it     
ex = exist(fullfile(expcasepath, expcasename), 'file'); 
if ex == 2
    % Load the experimental data
    exp_data = load(fullfile(expcasepath, expcasename));
    
    % Get akk if the data
    image_paths = exp_data.image_paths;
    image_names = exp_data.image_names;
    angles = exp_data.angles;
    images = exp_data.images;
    skeletons = exp_data.skeletons;
    rect_coords = exp_data.rect_coords;
    dateadded = exp_data.dateadded;
    % Get the number of test cases
    n = length(angles); 
    it = n + 1; 
else
    % Create cells to hold the cases 
    image_paths = cell(1,1); 
    image_names = cell(1,1); 
    angles = cell(1,1); 
    skeletons = cell(1,1); 
    rect_coords = cell(1,1); 
    images = cell(1,1);
    dateadded = cell(1,1); 
    % Set the iterator to 1 
    it = 1; 
end 
% Store the coordinates
rect_coords{it,1} = r; 
% Store the image names and pats 
image_paths{it,1} = im_struct.im_path; 
image_names{it,1} = im_struct.im_name; 

% Get todays date
date_format = 'yyyymmdd';
today_date = datestr(now,date_format);
dateadded{it,1} = today_date; 

% Get the orientation vectors and skeleton sections 
angles{it,1} = im_struct.orientim(r(2):r(2)+r(4), r(1):r(1)+r(3)); 
skeletons{it,1} = ...
    im_struct.skel_final_trimmed(r(2):r(2)+r(4), r(1):r(1)+r(3)); 
images{it,1} = mat2gray(im_struct.im(r(2):r(2)+r(4), r(1):r(1)+r(3))); 

% Save the .mat file or create it
if ex == 2
    save(fullfile(expcasepath, expcasename), ...
        'angles','skeletons','images','rect_coords',...
        'image_paths','image_names','dateadded','-append'); 
else
    save(fullfile(expcasepath, expcasename), ...
        'angles','skeletons','images','rect_coords',...
        'image_paths','image_names','dateadded'); 
end 

end

