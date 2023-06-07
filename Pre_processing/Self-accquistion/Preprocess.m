%% Prepare
close all;clc;clear all;
addpath('..\Function');
addpath('..\Function\Wavelet');
addpath('..\Function\codes_PHYSIONET_DATA');
addpath('..\Function\FourierTransform');
addpath('..\Function\EOG remove');
%% Load path
% Unchangeable: Don't change except you need use another function to load
% path file
% Select path file you want to load
[folder,name,ext]=Loadfile();
%% Load file
% Run this to load file
for i=1:length(name)
    if iscell(name)
        path=[folder{i},'\',name{i},ext{i}];
        disp(name{i});
    else
        path=[folder,'\',name,ext];
        disp(name);
    end
    load(path);
    channel_i=6;
    %% Preprocess with notch and band pass
    % Set up f_cut to filter
    fs=500;
    f_notch=50;
    f_high=70;
    f_low=.5;
    % Design notch filter
    % notch_spec=fdesign.notch('N,F0,Q',6,(f_notch*2/fs),10); % use with
    % fdesign
    % notch_filter=design(notch_spec);
    wo=f_notch/(fs/2);
    bw=wo/35;
    [b,a] = iirnotch(wo,bw);
    %% Apply filter
    for j=1:channel_i
        channel_name=['channel',num2str(j)];
        if exist('x_concentration')
        % Concentration
            x_raw=x_concentration.(channel_name);
        end
        % Rest
        if exist('x_rest')
            x_raw=x_rest.(channel_name);
        end
        if ~exist('x_concentration') & ~exist('x_rest')
            x_raw=load(path);
        end
        if ~isempty(find(isnan(x_raw)))
            i_nan=find(isnan(x_raw))
            x_raw(i_nan)=0;
        end

        %%
        filtered=filter(b,a,x_raw);
        filtered=lowpass(filtered,f_high,fs);
        filtered=highpass(filtered,f_low,fs);
        % filtered=bandpass(filtered,[0.5 70],fs);
         %% EOG remove reference
        [filtered EOG_estimate]=MTfilt(filtered,fs,0.97);
        filtered_save.(channel_name)=filtered;
        EOG_estimate_save.(channel_name)=EOG_estimate;
    end
    %% Clear var
    %% Save data
    % This section uses to save file, if your file name concentration, you save
    % concetration var, if your file name rest, you save file rest
    % Please run this section twice to save concentration and rest
    if ~exist('path_save')
        folder_save=uigetdir;
    end
    if iscell(name)
        path_save=[folder_save,'\',name{i}];
    else
        path_save=[folder_save,'\',name];
    end
    if exist('x_concentration')
        % Concentration
        save([path_save,'.mat'],'filtered_save');
        save([folder_save,'\EOG\',name{i},'_EOG.mat'],'EOG_estimate_save');
        clear x_concentration
    end
    % Rest
    if exist('x_rest')
        save([path_save,'.mat'],'filtered_save');
        save([folder_save,'\EOG\',name{i},'_EOG.mat'],'EOG_estimate_save');
        clear x_rest;
    end
    if ~exist('x_concentration') & ~exist('x_rest')
        save([path_save,'.mat'],'filtered_save');
        save([folder_save,'\EOG\',name{i},'_EOG.mat'],'EOG_estimate_save');
    end
    if ~iscell(name)
        break;
    end
end