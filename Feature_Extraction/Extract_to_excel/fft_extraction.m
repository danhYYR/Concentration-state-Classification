%% Add path
close all;clc;clear all;
addpath('..\..\Function');
addpath('..\..\Function\Wavelet');
addpath('..\..\Function\codes_PHYSIONET_DATA');
addpath('..\..\Function\FourierTransform');
%% Classification
% feature: Delta-Theta-Alpha-Beta-Gamma
%% Load file
[folder,name,ext]=Loadfile();
path=[folder,'\',name];
%% FGet save path
if ~exist('folder_save')
    folder_save=uigetdir;
    mkdir ([folder_save,'\Concentration']);
    mkdir ([folder_save,'\Concentration_high'])
    mkdir ([folder_save,'\Rest']);
end
i_sample=1;
%% Load data
for i=1:length(name)
    if iscell(name)
        path=[folder{i},'\',name{i},ext{i}];
        disp(name{i});
        sample_file=length(name);
    else
        path=[folder,'\',name,ext];
        disp(name);
        sample_file=1;
    end
    data=load(path);
    channel_min=1;
    channel_i=2;
    if isstruct(data)
        filtered_save=data.('filtered');
    else
        filtered_save=data;
    end
    path_split=strsplit(path,'\');
    name_split=strsplit(path_split{end},'_');
    fs=1000;
    for j=channel_min:channel_i
        channel_name=['channel',num2str(j)];
        filtered=filtered_save(:,j);
        [p,f]=pspectrum(filtered,fs);
        p_data(:,j)=p';
    end
    %% Condition file label
     if strcmp(name_split{2},'concentration') || ...
            sum(name_split{1}(1:3)=='Con')==3||...
            strcmp(name_split{2},'attention')||...
            strcmp(name_split{2},'attention.txt')
        if (~strcmp(name_split{3},'high'))
            path_save=[folder_save,'\Concentration\',name{i},'.csv'];        
        else
            path_save=[folder_save,'\Concentration_high\',name{i},'.csv'];        
        end
    end
    if strcmp(name_split{2},'rest')|| ...
            sum(name_split{1}(1:3)=='Res')==3||...
            strcmp(name_split{2},'inattention')||...
            strcmp(name_split{2},'inattention.txt')
        path_save=[folder_save,'\Rest\',name{i},'.csv'];
    end
    %% Save file
    writematrix(p_data,path_save);
    if ~iscell(name)
        break;
    end
end

