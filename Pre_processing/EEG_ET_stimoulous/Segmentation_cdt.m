%% Prepare
close all;clc;clear all;
run('..\..\Function\load_function.m')
%% Load path
% Unchangeable: Don't change except you need use another function to load
% path file
% Select path file you want to load
folder_list=dir(uigetdir('..\..\..\EEGData\Reference\'));
ext='.cdt';
channel_get=[1:64];
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
        folder_save=uigetdir('..\..\Data_save\Segmentation\EEG_ET_stimoulous');
    end
    if iscell(name)
        path_save=[folder_save,'\',name{i}];
    else
        path_save=[folder_save,'\',name];
    end
    %% Load path
    % Get event file
    event=Loadeventdata(path);
    % Load data per channel
    % Load one channel
%     data=Loaddatasinglechannel(path,channel_get,event{1}(2),event{1}(1));
    % Load all channel
    data=Loaddatasinglechannel(path,event{1}(2),event{1}(2),event{1}(1));
    data=data(:,channel_get);
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
    for j=1:channel_get
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
    % Save Baseline focus
    writematrix(x_concentration_1,[path_save,'_concentration_1.txt']);
    writematrix(x_concentration_2,[path_save,'_concentration_2.txt']);    
    % Save Concentration after intervention
    writematrix(x_concentration_high_1,[path_save,'_concentration_high_1.txt']);
    writematrix(x_concentration_high_2,[path_save,'_concentration_high_2.txt']);
    % Save Rest
    writematrix(x_rest_1,[path_save,'_rest_1.txt']);    
    writematrix(x_rest_2,[path_save,'_rest_2.txt']);
    clearvars -except ext channel_get folder_list folder_save 
end
beep