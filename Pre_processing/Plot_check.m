%% Prepare
% close all;clc;clear all;
run('..\Function\load_function.m')
%% Load path
% Unchangeable: Don't change except you need use another function to load
% path file
% Select path file you want to load
[folder,name,ext]=Loadfile('.mat','..\Data_save\');
% Run this to load file
%% Load path
channel_get=2;
path=[folder,'\',name,ext];
disp(name);
x_raw=load(path);
% x_raw=readmatrix(path);
% File raw
if isstruct(x_raw)
    fields=fieldnames(x_raw);
    if length(fields)==1
        data_raw=x_raw;
        x_raw=x_raw.(fields{1});
        fields=fieldnames(data_raw);
    end
%     fs=x_raw.('sampFreq');
%     x_raw=x_raw.('data');
%     channel_i=[4:17];
%     % The ADC bit resolution
%     adc_res=2^14;
end
%% Self recored
fs=1000;
channel_i=[1:6];

    %% Plot data
    % Selected session
    j=1;
    t=[1:length(x_raw)];
    % Plot Raw data
    figure
%     subplot(1,2,1)
    h(1)=plot(t,x_raw(:,j));
    title('Raw data')
    xlabel('t (s)')
    ylabel('Amplitude(\muV)');
%     axis([1 t(end) -150 150]);
%     axis([1 t(end) -150 150]);
    ax(1)=gca;
%     % Plot Data after filter
%     subplot(1,1,2)
%     h(2)=plot(t,filtered(:,j));
%     title('Filtered data')
%     xlabel('t (s)')
%     ylabel('Amplitude(\muV)')
%     axis([1 t(end) min(filtered(:,channel_i(j))) max(filtered(:,channel_i(j)))]);
%     axis([1 t(30*fs) -150 150]);
%     ax(2)=gca;
% %     Change axis label
%     ax(1).XTickLabel=ax(1).XTick./fs;
%     ax(2).XTickLabel=ax(2).XTick./fs;
%% Plot with fft
% Raw
[PSD,f]=fft_function(x_raw(:,j),fs,"Power_Density");
L=length(x_raw);
i_fEEG=find(f>=0.5);
figure
% subplot(2,1,1)
plot(f(i_fEEG),PSD(i_fEEG))% Magic number 2
title('Power Spectrum Destiny of Raw data')
xlabel('f (Hz)')
ylabel('PSD (\muV^2/Hz)')
axis([0 50 0 50])
% % Filtered
% [PSD,f]=fft_function(filtered(:,j),fs,"Power_Density");
% L=length(x_raw);
% i_fEEG=find(f>=0.5);
% subplot(2,1,2)
% plot(f(i_fEEG),PSD(i_fEEG))% Magic number 2
% title('Power Spectrum Destiny of Filtered data')
% xlabel('f (Hz)')
% ylabel('PSD (\muV^2/Hz)')
% axis([0 50 0 50])
 %%
[p,f]=pspectrum(x_raw(:,channel_i(j)),fs);
figure;
plot(f,p,'LineWidth',1.25,'color','b');
axis([0 60 0 50])
title('Power Spectrum Destiny of raw data')
xlabel('f (Hz)')
ylabel('PSD (\muV^2/Hz)')
%% Check with power spectrogram
% pspectrum(x_raw(:,channel_i(j)),fs,'spectrogram','FrequencyLimits',[0 70],'TimeResolution',5,'OverlapPercent',30);
%     %% Check with power spectrogram
%     figure
%     [p,f,t]=pspectrum(filtered(:,channel_i(j)),fs,'spectrogram','FrequencyLimits',[0 70],'TimeResolution',30,'OverlapPercent',30);
%     norm=Normalize(p)./sum(p);
%     mesh(f,t,norm');
%     view(90,-90)   