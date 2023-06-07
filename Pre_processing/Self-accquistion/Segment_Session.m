%% Add path
close all;clc;clear all;
run('..\..\Function\load_function.m')
%% Load path
% Unchangeable: Don't change except you need use another function to load
% path file
% Select path file you want to load
% path_file='..\..\EEGData\Attention';
path_file='C:\Users\LAPTOP\My Drive\EEG\Result\Attention\Data';
path_folder=uigetdir(path_file,'Choose folder to autoload');
% Getpath save
if ~exist('folder_save')
    folder_save=uigetdir('..\..\Data_save\Raw_data\Self_accquistion','Choose where do you want to save');
end
% Get a list of all subfolders in the root folder
subfolders = dir(path_folder);
subfolders = subfolders([subfolders(:).isdir] & ~ismember({subfolders(:).name}, {'.', '..'}));

%% Loop over each subfolder and process its files
for i = 1:length(subfolders)
    subfolder = subfolders(i);
    subfolderPath = fullfile(path_folder, subfolder.name);
    
    % Get a list of all files in the subfolder
    files = dir(fullfile(subfolderPath, '*.txt'));
    %% Loop over each file and encode the subject name
    for j = 1:length(files)
        file = files(j);
        fileName = file.name;
        % Extract the subject name from the file name
        exp1='^FCS_(?<name>Subject\d+)_[M]\d+_(?<session>\d*[0-9])\w+.txt$';
        exp2='^FCS_(?<name>Subject\d+)_[F][M]\d+_(?<session>\d*[0-9])\w+.txt$';
        tokens = regexp(fileName, exp1, 'names');
        if isempty(tokens)
            tokens = regexp(fileName, exp2, 'names');
        end
        if isempty(tokens)
            continue % Skip files that do not match any of the expected patterns
        end
        subject_id = tokens.name;
        path_data=fullfile(subfolderPath, fileName);
        path_event = fullfile(subfolderPath,['E_',fileName]);
        %% LoadEEG
        x_raw=readmatrix(path_data);
        event=get_event_segments(path_event);
        fs=500;
        EEG=load_EEG(x_raw, event, fs,'off');
        % Fix event
        %% Save data
        path_save=fullfile(folder_save,subject_id);
        save([path_save,'.mat'],'EEG');
    end
end
%% Ending Script
beep