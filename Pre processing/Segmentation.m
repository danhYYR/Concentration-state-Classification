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
% We have two part: Unchangeable and changeable 
% 

%% Prepare add function 
close all;clc;clear all;
% Changeable
% Change path and add more path inculde your function
addpath('..\Function');
addpath('..\Function\Wavelet');
addpath('..\Function\codes_PHYSIONET_DATA');
addpath('..\Function\FourierTransform');
%% Load path
% Unchangeable: Don't change except you need use another function to load
% path file
% Select path file you want to load
[folder,name,ext]=Loadfile();
%% Load file
% Run this to load file
for i=1:length(name)
    if iscell(name)
        path=[folder{i},'\',name{i}];
        disp(name{i});
        event=readcell([folder{i},'\E_',name{i}]);
    else
        path=[folder,'\',name];
        event=readcell([folder,'\E_',name]);
        disp(name);
    end
    data=Loaddata(path);
    channel_i=6;
    %% Load event 
    % Changeable
    % Check and change event time each file EEG records
    session=5;
    fs=500;
    if length(event{10,1})>5
    % Index event start= regexp(event_start,'\d+)'
        i_event_start=regexp(event{10,1},'\d');
        i_event_s=regexp(event{11,1},'\d');
        event_start=duration(event{10,1}(i_event_start(1):i_event_start(end-4)));
        event_s=duration(event{11,1}(i_event_s(1):i_event_s(end-4)));
    else
        event_start=event{10,2};
        event_s=event{11,2};
    end
    duration_neutral=duration("00:03:00");
    % Dont change duration time if you use our experiment
    duration_concentration=duration("00:00:30");
    duration_rest=duration("00:00:30");
    duration_state=duration("00:05:00");
    duration_break=duration("00:00:05");
    option = questdlg('Is data including delay ? ',...
        'Option',...
        'Yes','No','No');
    if  option=="Yes"
        prompt = {'Enter delay duration'};
        dlgtitle = 'Delay duration format hh:mm:ss';
        dims = [1 55];
        definput = {'00:00:03'};%magic default number
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        
    else
        answer{1}="00:00:00";
    end
    duration_delay=duration(answer{1});
    % Dont change below
    t_min_index=seconds(event_start)*fs;;
    t_max_index=seconds(event_start+duration_neutral)*fs;
    time_range_neutral=[t_min_index,t_max_index];
    t_min_index=seconds(event_s)*fs;;
    t_max_index=seconds(event_s+duration_state+duration_break*(session-1)+duration_delay*session)*fs;
    time_range_state=[t_min_index,t_max_index];
    time_concentration=seconds(duration_concentration)*fs;
    time_rest=seconds(duration_rest)*fs;
    time_break=seconds(duration_break)*fs;
    time_delay=seconds(duration_delay)*fs;
    t_neutral=[time_range_neutral(1,1):time_range_neutral(1,2)]';
    if length(data)<time_range_state(1,2)
        event_fix=length(data)/fs-seconds(duration_state+duration_break*(session-1)+duration_delay*session);
        event_fix=[floor(event_fix/60),event_fix-floor(event_fix/60)*60]
        event_s=duration(0,event_fix(1,1),event_fix(1,2))
        t_min_index=seconds(event_s)*fs;;
        t_max_index=seconds(event_s+duration_state+duration_break*(session-1)+duration_delay*session)*fs;
        time_range_state=[t_min_index,t_max_index];
    end
    %% Load data
    % Unchangeable: Don't change except you want to use another script
    for j=1:channel_i
        channel_name=['channel',num2str(j)];
        x=data(:,j);
        x_neutral=x(time_range_neutral(1,1):time_range_neutral(1,2));
        i_concentration=[time_range_state(1,1):time_concentration+time_rest+time_break+time_delay:time_range_state(1,2)];
        if length(i_concentration)>5
            i_concentration(end)=[];
        end
        x_concentration_i = arrayfun(@(s) x(s:s+time_concentration-1), i_concentration, 'UniformOutput', false);
        x_concentration.(channel_name)=cell2mat(x_concentration_i);
        i_rest=i_concentration+time_concentration+time_delay;
        x_rest_i=arrayfun(@(s) x(s:s+time_rest-1), i_concentration+time_concentration, 'UniformOutput', false);
        x_rest.(channel_name)=cell2mat(x_rest_i);
        
    end
    %% Save data
    % This section uses to save file, if your file name concentration, you save
    % concetration var, if your file name rest, you save file rest
    % Please run this section twice to save concentration and rest
    if ~exist('folder_save')
        folder_save=uigetdir;;
    end
    if iscell(name)
        path_save=[folder_save,'\',name{i}];
    else
        path_save=[folder,'\',name];
    end
    save([path_save,'_concentration.mat'],'x_concentration');
    save([path_save,'_rest.mat'],'x_rest');
    if ~iscell(name)
        break;
    end
end
