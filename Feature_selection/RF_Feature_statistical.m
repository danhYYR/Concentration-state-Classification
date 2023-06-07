%% Prepare
close all;clc;clear all;
run('..\Function\load_function.m')
%% Run this to load file
path_file='..\Data_save\Result\Classification\Self-accquistion\Thesis';
path_folder=uigetdir(path_file,'Choose folder to autoload');
% Getpath save
if ~exist('folder_save')
    folder_save=uigetdir('..\Data_save\Result\Statistical\Feature Importance','Choose where do you want to save');
end
% Get a list of all subfolders in the root folder
subfolders = dir(path_folder);
subfolders = subfolders([subfolders(:).isdir] & ~ismember({subfolders(:).name}, {'.', '..'}));
%% Loop over each subfolder and process its files
for i = 1:length(subfolders)
% i_error=8;
% for i = i_error:i_error
    subfolder = subfolders(i);
    subfolderPath = fullfile(path_folder, subfolder.name);
    % Get Channel Folder
    channel_folders = dir(fullfile(subfolderPath));
    channel_folders = channel_folders([channel_folders(:).isdir] & ~ismember({channel_folders(:).name}, {'.', '..'}));
   
    %% Check to save
    subject_id=subfolders(i).name;
    disp(subject_id);
    disp('Remain');
    disp(length(subfolders)-i);
   %% Load RF Feature importance
    for j=1:length(channel_folders)
        channel_subfolder = channel_folders(j);
        channel_folderPath = fullfile(channel_subfolder.folder, channel_subfolder.name);
        path_controller(channel_folderPath);
    end
end
function path_controller(path)
    files = dir(fullfile(path, '*.mat'));
    i=1
        file = files(i);
        fileName = file.name;
        
        Model_RF=loadCompactModel(fullfile(file.folder,fileName));

        feature_rank=Feature_selection_control(Model_RF,'Random Forest');

end
function feature_rank=RF_importance(model)
end