%% Add path
close all;clc;clear all;
addpath('..\Function');
addpath('..\Function\Wavelet');
addpath('..\Function\codes_PHYSIONET_DATA');
addpath('..\Function\FourierTransform');
%% Classification
% feature: Delta-Theta-Alpha-Beta-Gamma
%% Load file
[folder,name,ext]=Loadfile();
path=[folder,'\',name];
%% Run this to load file
disp(name);
sample_file=1;
load(path);
channel_i=2;
%%
i=1
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
% RatioAlpha/Gamma
data(:,12)=data(:,3)./data(:,5);
p_gr=[ones(floor(length(data)/2),1);-1*ones(floor(length(data)/2),1)];
p_label=categorical(data(:,end),value_label,label);
[tau p]=corr(data,p_gr,'Type','Kendall');
fs_tau=find(abs(tau)>=0.2);
% Tau cross correlation
[tau_cross p]=corr(data(:,fs_tau),'Type','Kendall');
fs_tau_cross=find(abs(tau_cross)<=0.5);