%% Add path
close all;clc;clear all;
run('..\..\Function\load_function.m')
%% Load path
% Unchangeable: Don't change except you need use another function to load
% path file
% Select path file you want to load
% path_file='..\..\EEGData\Attention';
path_file='..\..\Data_save\Raw_data\Self_accquistion';
[folder,name,ext]=Loadfile('.mat',path_file);
% Getpath save
if ~exist('folder_save')
    folder_save=uigetdir('..\..\Data_save\Filtered\Self_accquistion\Thesis','Choose where do you want to save');
end
%% Load file
% Run this to load file
for i=1:length(name)
    if iscell(name)
        path=[folder{i},'\',name{i},ext{i}];
        disp(name{i});
        disp('Remain')
        disp(length(folder)-i)
    end
    % Data specific with EEG 
    load(path);
    % Meta data
    data=EEG.data;
    fs=EEG.srate;
    i_channel=[1:6];
    num_trial=5;
    % Preapare filter parameter
    f_notch=50;
    f_high=70;
    f_low=.5;
    f_band=[f_low f_high];
    % Design notch filter
    % notch_spec=fdesign.notch('N,F0,Q',6,(f_notch*2/fs),size(event,1)-1); % use with
    % fdesign
    % notch_filter=design(notch_spec);
    wo = 50/(fs/2); %notch frequency at 50Hz
    q = 1; %quaity factor q=wo/bw
    bw = wo/q;
    [b,a]= iirnotch(wo,bw);
    %% Load data with channel
    %% Filter with wavlet
    % Unchangeable: Don't change except you want to use another script
    filtered=filter_butterworth(EEG.data,EEG.srate,i_channel ,f_band);
    EEG.filtered=filtered;
    %% Save data
    if iscell(name)
        path_save=[folder_save,'\',name{i}];
    else
        path_save=[folder_save,'\',name];
    end
        % This section uses to save file, if your file name concentration, you save
        % concetration var, if your file name rest, you save file rest
        % Please run this section twice to save concentration and rest
    save([path_save,'.mat'],'EEG');
    clearvars -except folder name ext folder_save
    %% Break
    if ~iscell(name)
        break
    end
end
beep