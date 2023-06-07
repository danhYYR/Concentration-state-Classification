%% Prepare
close all;clc;clear all;
addpath('..\..\Function');
addpath('..\..\Function\Wavelet');
addpath('..\..\Function\codes_PHYSIONET_DATA');
addpath('..\..\Function\FourierTransform');
addpath('..\..\Function\EOG remove');
addpath('..\..\Function\Pre_Processing');

%% Load path
% Unchangeable: Don't change except you need use another function to load
% path file
% Select path file you want to load
[folder,name,ext]=Loadfile('.txt','..\..\..\EEGData\Reference\Mental state');
%% Get save folder
if ~exist('path_save')
    folder_save=uigetdir('..\..\Data_save\Filtered\Reference\Mental_state','Choose where do you want to save');
end
% Create EOG folder
if iscell(folder)
    % Get Subject id
    i_subject=strsplit(folder{end},'\');
    i_subject=i_subject{end};
    folder_save_subject=[folder_save,'\',i_subject];
    % Create folder to save
    mkdir (folder_save_subject);
    mkdir ([folder_save_subject,'\EOG'])
end
%% Preprocess with notch and band pass
% Set up f_cut to filter
fs=128;
%% Load file
% Run this to load file
for i=1:length(name)
    if iscell(name)
        % Get path
        path=[folder{i},'\',name{i},ext{i}];


        disp(name{i});
        disp('Remain')
        disp(length(name)-i)
    else
        path=[folder,'\',name,ext];
        disp(name);
    end
    %% Load file
    x_raw=load(path);
    if isstruct(x_raw)
    fields=fieldnames(x_raw);
    if length(fields)==1
        data_raw=x_raw;
        x_raw=x_raw.(fields{1});
        fields=fieldnames(x_raw);
        fs=x_raw.('sampFreq');
        x_raw=x_raw.('data');
        i_channel=[4:17];
    end
else
    fs=128;
    i_channel=[4:17];
    end
    %% Pre preocessing step
    eeg=emotiv_filter(x_raw,[1 length(x_raw)],'FIR');
    [~, EOG_estimate]=MTfilt(eeg,fs,0.97);
    filtered=eeg;
    %% Save file 
    if iscell(name)
        path_save=[folder_save_subject,'\',name{i}];
        path_save_EOG=[folder_save_subject,'\EOG\',name{i}];
    else
        path_save=[folder_save_subject,'\',name];
        path_save_EOG=[folder_save_subject,'\EOG\',name];
    end
    save([path_save,'_filtered.mat'],'filtered');
    save([path_save_EOG,'_EOG.mat'],'EOG_estimate');
    clearvars x_raw filtered
    if ~iscell(name)
        break
    end
end
beep
