%% Prepare
close all;clc;clear all;
run('..\Function\load_function.m')
%% Load path
% Unchangeable: Don't change except you need use another function to load
% path file
% Select path file you want to load
% path_file='C:\Users\LAPTOP\My Drive\EEG\Result\Attention\Data';
path_file='..\Data_save\Filtered\Self_accquistion\Thesis';
[folder,name,ext]=Loadfile('.mat',path_file);
% Run this to load file
%% Load path
channel_get=2;
data_path=[folder,'\',name,ext];
disp(name);
load(data_path);
%% Plotting
channel=2;
%% Annotation
ax(1)=plotting(EEG,channel,'Annotation');
%% Time domain
ax(2:3)=plotting(EEG,channel,'Time');
%% Frequency domain
ax(4:5)=plotting(EEG,channel,'Frequency');
%% Change axis
set(figure(1),'WindowState','maximized');
set(figure(2),'WindowState','maximized');

% Change axis label
ax(1).XTickLabel=ax(1).XTick./EEG.srate;
ax(2).XTickLabel=ax(2).XTick./EEG.srate;
ax(3).XTickLabel=ax(3).XTick./EEG.srate;
