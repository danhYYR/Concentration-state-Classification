%% Prepare
close all;clc;clear all;
run('..\..\Function\load_function.m')
%% Preprocess with notch and band pass
% Set up f_cut to filter
fs=1000;
f_notch=50;
f_high=40;
f_low=0.5;
% Design notch filter
% notch_spec=fdesign.notch('N,F0,Q',6,(f_notch*2/fs),10); % use with
% fdesign
% notch_filter=design(notch_spec);
% wo=f_notch/(fs/2);
% bw=wo/35;
% [b,a] = iirnotch(wo,bw);
% Design notch filter
notch_spec=fdesign.notch('N,F0,Q',6,(f_notch*2/fs),10); %
% fdesign
notch_filter=design(notch_spec);
%% Load path
% Unchangeable: Don't change except you need use another function to load
% path file
% Select path file you want to load
folder_list=dir(uigetdir('..\..\..\EEGData\EEG_ET_simoulous\'));
ext='.cdt';
% Channel list: Fp1,Fp2,C3,C4,O1,O2,Cz
channel_get=[1,3,26,30,61,63,28];
%% Load file
% Run this to load file
%%
for i=3:length(folder_list) 
    folder=[folder_list(i,:).('folder'),'\',folder_list(i,:).('name')];
    name_split=strsplit(folder_list(i,:).('name'),'_');
    name=name_split{end};
    path=[folder,'\Experiment2_CCT\CCT_EEG\',name,'_CCT_EEG',ext];
    disp(name);
    disp('Remain')
    disp(length(folder_list)-i)
    %% Get path save
    if ~exist('folder_save')
        folder_save=uigetdir('..\..\Data_save\Filtered\Reference\EEG_ET_simoulous');
    end
    if iscell(name)
        path_save=[folder_save,'\',name{i}];
    else
        path_save=[folder_save,'\',name];
    end
        mkdir ([folder_save,'\EOG'])
    %% Load path
    % Get event file
    event=Loadeventdata(path);
    % Load data per channel
    % Load one channel
%     data=Loaddatasinglechannel(path,channel_get,event{1}(2),event{1}(1));
    % Load all channel
    data=Loaddatasinglechannel(path,event{1}(2),event{1}(2),event{1}(1));
    x_raw=data(:,channel_get);
    %% Apply filter
    %% Filter simple
%     filtered=filter(notch_filter,x_raw);
    filtered=x_raw;
    filtered=lowpass(filtered,f_high,fs,'ImpulseResponse','iir');
    filtered=highpass(filtered,f_low,fs,'ImpulseResponse','iir');
    %     filtered=bandpass(filtered,[0.5 70],fs);
    %% Plot data in time domain
    %% EOG remove reference
    [filtered EOG_estimate]=MTfilt(filtered,fs,0.97);
    %% Save file 
    if iscell(name)
        path_save=[folder_save,'\',name{i}];
        path_save_EOG=[folder_save,'\EOG\',name{i}];
    else
        path_save=[folder_save,'\',name];
        path_save_EOG=[folder_save,'\EOG\',name];
    end
    % Remove 30 second from start
%     filtered=filtered(30*fs:end,:);
    save([path_save,'_filtered.mat'],'filtered');
    save([path_save_EOG,'_EOG.mat'],'EOG_estimate');
    clearvars x_raw filtered data
end
beep
