% Add path
close all;clc;clear all;
addpath('..\Function');
addpath('..\Function\Wavelet');
addpath('..\Function\codes_PHYSIONET_DATA');
addpath('..\Function\FourierTransform');
% Feature: Delta-Theta-Alpha-Beta-Gamma in file mat
%% Load file
[folder,name,ext]=Loadfile();
path=[folder,'\',name];
%% Run this to load file
disp(name);
sample_file=1;
load(path);
channel_i=2;
%% Feature header
statistical_feature={'Delta',...
                    ;'Theta',...
                    ;'Alpha',...
                    ;'Beta',...
                    ;'Gamma (30-70 Hz)',...
                    ;'Beta/Theta',...
                    ;'Alpha/Beta',...
                    ;'Theta/Alpha',...
                    ;'Alpha+Beta+Gamma',...
                    ;'Theta/Beta',...
                    ;'Beta/(Theta+Alpha)',...
                    ;'Alpha/Gamma',...
                    ;'Label'};
%% Save with excel
if ~exist('folder_save')
    folder_save=uigetdir;
end
path_save=[folder_save,'\','Feature Extraction.xlsx'];
%% Run for all channel
for i=1:channel_i
    %% Run for channel i
    channel_name=['channel',num2str(i)];
    data=vertcat(p_data.(channel_name));
    label={'Rest','Concentration'};
    value_label=[-1,1];
    n=length(data);
    % Beta/Theta
    data(:,6)=data(:,4)./data(:,2);
    % Alpha/Beta
    data(:,7)=data(:,3)./data(:,4);
    % Theta/Alpha
    data(:,8)=data(:,2)./data(:,3);
    % Sum Alpha Beta Gamma
    data(:,9)=sum(data(:,3:5),2);
    % Ratio Theta/Beta
    data(:,10)=data(:,2)./data(:,4);
    % Ratio Beta/(Alpha+Theta)
    data(:,11)=data(:,4)./sum(data(:,2:3),2);
    % Ratio Alpha/Gamma
    data(:,12)=data(:,3)./data(:,5);
    % Label
    p_gr=[ones(length(data)/2,1);-1*ones(length(data)/2,1)];
    data(:,13)=p_gr;
    p_label=categorical(data(:,end),value_label,label);
    %% Save data to xlsx 
    statistical_data=num2cell(data);
    table_save= vertcat(statistical_feature',statistical_data);
    writecell(table_save,path_save,'Sheet',['Sheet',num2str(i)]);
end