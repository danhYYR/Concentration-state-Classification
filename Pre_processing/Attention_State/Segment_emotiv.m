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
folder_list=dir(uigetdir('..\..\..\EEGData','Choose folder to segment'));
channel_i=[4:17];
i_subject=[3 10 17 24 29];
i_trial=7;
%% Load file
% Run this to load file
%% Load path
channel_get=length(channel_i);
for i=4:length(folder_list) 
    %% Check path
    folder=folder_list(i,:).('folder');
    name=folder_list(i,:).('name');
    path=[folder,'\',name];
    name_split=strsplit(folder_list(i,:).('name'),'_');
    name=name_split{end}(1:end-4);
    disp(name);
    disp('Remain')
    disp(length(folder_list)-i)
    %% Get path save
    if ~exist('folder_save')
        folder_save=uigetdir('..\..\Data_save\Segmentation','Choose folder to save');
    end
    if iscell(name)
        path_save=[folder_save,'\',name{i}];
    else
        path_save=[folder_save,'\',name];
    end
    %% Load data
    x_raw=load(path);
    if isstruct(x_raw)
        fields=fieldnames(x_raw);
        if length(fields)==1
            % Check x_raw raw from .mat file
    %         x_raw_raw=x_raw;
        % Get x_raw from struct
            x_raw=x_raw.(fields{1});
            x_raw=x_raw.('data');
        end
    end
    fs=128;
%     fs=x_raw.('sampFreq');
    %% Segment x_raw
    % Unit minute
    % Event marker get from paper: 0-10 is focus; 10-20 is unfocus; the rest of
    % x_raw is drowse
    % Attention event
    duration_attention=10;
    i_attention=[1:duration_attention*60*fs];
    % Inattention event
    duration_inattention=10;
    i_inattention=[i_attention(end)+1:i_attention(end)+duration_inattention*60*fs];
    % Drowse event
    duration_drowse=(length(x_raw)-duration_attention*60*fs-duration_inattention*60*fs)/(60*fs);
    i_drowse=[i_inattention(end)+1:length(x_raw)];
    %% Get x_raw after processing 
    eeg=emotiv_filter(x_raw,[1 length(x_raw)],'Raw');
    %% Segment EEG_x_raw
    for j=1:channel_get
        channel_name=['channel',num2str(j)];
        % Get Attention
        x_attention(:,j)=eeg(i_attention,channel_i(j));
        % Get Inattention 
        x_inattention(:,j)=eeg(i_inattention,channel_i(j));
        % Get Drowse
        x_drowse(:,j)=eeg(i_drowse,channel_i(j));
    end
    %% Save EEG_x_raw
    % This section uses to save file, if your file name concentration, you save
    % concetration var, if your file name rest, you save file rest
    % Please run this section twice to save concentration and rest
    % Save Focus
    writematrix(x_attention,[path_save,'_attention.txt']);  
    % Save UnFocus
    writematrix(x_inattention,[path_save,'_inattention.txt']);
    % Save Drowse
%     writematrix(x_drowse,[path_save,'_drowse.txt']);    
    clearvars -except ext channel_get folder_list folder_save channel_i
end
beep