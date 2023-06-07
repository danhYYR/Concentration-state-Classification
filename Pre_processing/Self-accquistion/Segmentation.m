%% Sript description
%  We have developed a script to segment data
% # Data and event Format
%   Data and event must be named following format <Data_name>= <Name research>_<Name subject>_<Measurment_index>
%   Event must be named = E_<Data_name>
% # Features
% This script using segment data with each segment duration 
% In this script we have: Load multidata, Segment follow duartion,Save file
% in folder where you want
% ## Segment
%   This feature is segementating with 5 segment you can change if you want
%   time_<event> variables are index unit (that mean in 1s t_<event> have fs index)   
% # Part 
% We have two parts: Unchangeable and changeable 
% 
%% Add path
close all;clc;clear all;
run('..\..\Function\load_function.m')
%% Select path file you want to load
% path_file='..\..\EEGData\Attention';
path_file='..\..\Data_save\Filtered\Self_accquistion\Thesis';
[folder,name,ext]=Loadfile('.mat',path_file);
% Getpath save
if ~exist('folder_save')
    folder_save=uigetdir('..\..\Data_save\Segmentation\Self- accquistion\Thesis','Choose where do you want to save');
end
%% Generate subfolder to save local file
exp='(?<name>Subject\d+)_(?<session>\d*)';
tokens = regexp(name, exp, 'names');
% Get name file
subject_id = cellfun(@(x) x.name,tokens,'UniformOutput',false);
name_subject=unique(subject_id);
for i=1:length(name_subject)
    % Extract the subject name from the file name
    mkdir(fullfile(folder_save,name_subject{i}));
end
%% Load file
% Run this to load file
for i=1:length(name)
    if iscell(name)
        path=[folder{i},'\',name{i}];
        path_event=[folder{i},'\E_',name{i}];
        disp(name{i});
        disp('Remain')
        disp(length(folder)-i)
    else
        break;
    end
    %% Data specific with EEG 
    load(path);
    % Meta data
    data=EEG.data;
    fs=EEG.srate;
    i_channel=[1:6];
    num_trial=5;
    %% Get event
    event=EEG.event;
    i_concentration=[];
    i_rest=[];
    for j=1:length(event)
        switch (event{j,1})
            case 'Concentration'
                i_concentration(j).latency=event{j,2};
                i_concentration(j).duration=event{j,3};
            case 'Rest'
                i_rest(j).latency=event{j,2};
                i_rest(j).duration=event{j,3};
        end
    end
    idx_null=arrayfun(@(t) isempty(t.latency),i_concentration);
    idx_null=find(idx_null);
    i_concentration(idx_null)=[];
    idx_null=arrayfun(@(t) isempty(t.latency),i_rest);
    idx_null=find(idx_null);
    i_rest(idx_null)=[];
    %% Segment data
    x=EEG.filtered;
    x_concentration = arrayfun(@(s) x(s.latency:s.latency+s.duration,:), i_concentration, 'UniformOutput', false);
    x_rest = arrayfun(@(s) x(s.latency:s.latency+s.duration,:), i_rest, 'UniformOutput', false);
    %% Get save path
    exp='(?<name>Subject\d+)_(?<session>\d*)';
    tokens = regexp(name{i}, exp, 'names');
    subfolder_save=fullfile(folder_save,tokens.name);
    %% Save data
    for j=1:num_trial
        % This section uses to save file, if your file name concentration, you save
        % concetration var, if your file name rest, you save file rest
        % Please run this section twice to save concentration and rest
        i_trial=['_Trial_',num2str(j)];
        path_save=fullfile(subfolder_save,[name{i},i_trial]);
        writematrix(x_concentration{j},[path_save,'_concentration.csv']);
        writematrix(x_rest{j},[path_save,'_rest.csv']);
    end
    clearvars -except folder name folder_save

end
