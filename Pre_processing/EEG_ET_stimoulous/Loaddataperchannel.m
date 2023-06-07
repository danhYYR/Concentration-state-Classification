%% Prepare
close all;clc;clear all;
addpath('..\..\Function');
addpath('..\..\Function\Importdata');
%% Load path
[folder,name,ext]=Loadfile('.cdt','..\..\..\EEGData\Reference');
%% Load file
path=[folder,'\',name,ext];
disp(name);
sample_file=1;
%% Load data per channel
% Get event data
% 1 is numsamples    
% 2 is numchannel   
% 3 is numTrials    
% 4 is samplingFreq  
% 5 is offsetUsec    
% 6 is isASCII       
% 7 is multiplex     
% 8 is sampleTime    
event=Loadeventdata(path);

data=Loaddatasinglechannel(path,event{1}(2),event{1}(2),event{1}(1));
