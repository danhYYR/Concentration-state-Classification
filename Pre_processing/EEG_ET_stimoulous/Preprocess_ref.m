%% Prepare
close all;clc;clear all;
run('..\..\Function\load_function.m')
%% Preprocess with notch and band pass
% Set up f_cut to filter
fs=1000;
f_notch=50;
f_high=40;
f_low=0.5;
f_band=[f_low f_high];
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
        mkdir(path_save);
    else
        path_save=[folder_save,'\',name];
        mkdir(path_save);  
    end  
        mkdir ([folder_save,'\EOG'])
    %% Load path
    % Get event file
    event=Loadeventdata(path);
    % Load data per channel
    % Load one channel
%     data=Loaddatasinglechannel(path,channel_get,event{1}(2),event{1}(1));
    % Load all channel
    data=Loaddatasinglechannel(path,[1:event{1}(2)],event{1}(2),event{1}(1));
    x_raw=data(:,channel_get);
    clear data
    %% Apply filter
    filtered =filter_butterworth(x_raw,fs,[1:size(x_raw,2)] ,f_band);
    %% Save file 
    if iscell(name)
        path_save=[path_save,'\',name{i}];
    else
        path_save=[path_save,'\',name];
    end
    % Remove 30 second from start
%     filtered=filtered(30*fs:end,:);
    save([path_save,'_filtered.mat'],'filtered');
%% Segment data
%% Load path
    % Get event file
    % get data to segment
    data=filtered;
    %% Load event+fs
    duration_rest=duration('00:02:00');
    fs=event{1}(4);
    % Find index event since load event file not similar
%     % Rest open
%     
%     t_min=event{2}(find(event{2}==2)-1);
%     t_max=t_min+seconds(duration_rest)*fs;
%     time_range_rest_open=[t_min,t_max];
    % Rest 
    t_start=find(event{2}==2)-1;
    t_min=event{2}(t_start(1));
    t_max=t_min+seconds(duration_rest)*fs;
    time_range_rest_1=[t_min,t_max];
    % Rest 2
    t_min=event{2}(t_start(2));
    t_max=t_min+seconds(duration_rest)*fs;
    time_range_rest_2=[t_min,t_max];
    % Find index event since load event file not similar
    % Baseline focus 1
    t_min=event{2}(find(event{2}==10)-1);
    t_max=event{2}(find(event{2}==12)-1);
    time_range_concentration_1=[t_min,t_max];
    % Base line focus 2
    t_min=event{2}(find(event{2}==15)-1);
    t_max=event{2}(find(event{2}==17)-1);
    time_range_concentration_2=[t_min,t_max];
    % Concenctration event after intervention 1
    t_min=event{2}(find(event{2}==30)-1);
    t_max=event{2}(find(event{2}==32)-1);
    time_range_concentration_high_1=[t_min,t_max];
    % Concenctration event after intervention 2
    t_min=event{2}(find(event{2}==35)-1);
    t_max=event{2}(find(event{2}==37)-1);
    time_range_concentration_high_2=[t_min,t_max];
    %% Segment EEG_data
    for j=1:length(channel_get)
        channel_name=['channel',num2str(j)];
        % Get Baseline focus event
        i_concentration=[time_range_concentration_1(1,1):time_range_concentration_1(1,2)];
        x_concentration_1(:,j)=data(i_concentration,j);
        i_concentration=[time_range_concentration_2(1,1):time_range_concentration_2(1,2)];
        x_concentration_2(:,j)=data(i_concentration,j);
        % Get Rest 
        i_rest=[time_range_rest_1(1,1):time_range_rest_1(1,2)];
        x_rest_1(:,j)=data(i_rest,j);
        i_rest=[time_range_rest_2(1,1):time_range_rest_2(1,2)];
        x_rest_2(:,j)=data(i_rest,j);
        % Get concentration after intervention
        i_concentration=[time_range_concentration_high_1(1,1):time_range_concentration_high_1(1,2)];
        x_concentration_high_1(:,j)=data(i_concentration,j);
        i_concentration=[time_range_concentration_high_2(1,1):time_range_concentration_high_2(1,2)];
        x_concentration_high_2(:,j)=data(i_concentration,j);
    end
    %% Save EEG_data
    % This section uses to save file, if your file name concentration, you save
    % concetration var, if your file name rest, you save file rest
    % Please run this section twice to save concentration and rest
    % Change path save to save segment file
    path_save_split=strsplit([folder_save,'\',name],'\');
    path_save_split{6}='Segmentation';    
    path_save=strjoin(path_save_split,'\');
    mkdir(path_save);
    path_save=[path_save,'\',name];
    % Save Baseline focus
    writematrix(x_concentration_1,[path_save,'_concentration_1.csv']);
    writematrix(x_concentration_2,[path_save,'_concentration_2.csv']);    
    % Save Concentration after intervention
    writematrix(x_concentration_high_1,[path_save,'_concentration_high_1.csv']);
    writematrix(x_concentration_high_2,[path_save,'_concentration_high_2.csv']);
    % Save Rest
    writematrix(x_rest_1,[path_save,'_rest_1.csv']);    
    writematrix(x_rest_2,[path_save,'_rest_2.csv']);
    clearvars -except ext channel_get folder_list folder_save fs f_band
end
beep
