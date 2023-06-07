%% Prepare
% close all;clc;clear all;
addpath('..\..\Function');
addpath('..\..\Function\Wavelet');
addpath('..\..\Function\codes_PHYSIONET_DATA');
addpath('..\..\Function\FourierTransform');
addpath('..\..\Function\EOG remove');
addpath('..\..\Function\Pre_Processing');
%% Load path
% Unchangeable: Don't change except you need use another function to load
% path file
% Select path file you want to load
[folder,name,ext]=Loadfile();
%% Load file
% Run this to load file
%% Load path
path=[folder,'\',name,ext];
x_raw=load(path);
if isstruct(x_raw)
    fields=fieldnames(x_raw);
    if length(fields)==1
        data_raw=x_raw;
        x_raw=x_raw.(fields{1});
        fields=fieldnames(x_raw);
        fs=x_raw.('sampFreq');
        x_raw=x_raw.('data');
        channel_i=[4:17];
    end
else
    fs=128;
    channel_i=[1:5];
end
channel_get=1;
eeg=emotiv_filter(x_raw(:,channel_i),[1:length(x_raw)]);
%% Plot data
filtered= eeg.firfilt(:,1);
t=[1:length(filtered)];
% Plot Raw data
figure
subplot(2,1,1)
h(1)=plot(t,eeg.raw(t,1));
title('Raw data')
xlabel('t (s)')
ylabel('Amplitude(\muV)');
%     axis([1 t(end) -150 150]);
%     axis([1 t(end) -150 150]);
ax(1)=gca;
% Plot Data after filter
subplot(2,1,2)
h(2)=plot(t,filtered);
title('Data filtered')
xlabel('t (s)')
ylabel('Amplitude(\muV)')
%     axis([1 t(end) min(filtered(:,channel_i(j))) max(filtered(:,channel_i(j)))]);
axis([1 length(t) -150 150]);