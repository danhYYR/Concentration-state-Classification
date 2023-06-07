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
%% Load path
path=[folder,'\',name,ext];
fs=500;
x_raw=readmatrix(path);
if isstruct(x_raw)
    fields=fieldnames(x_raw);
    if length(fields)==1
        data_raw=x_raw;
        x_raw=x_raw.(fields{1});
        fields=fieldnames(x_raw);
    end
end

%% Self- Recorded
channel_i=[1:6];
i_nan=find(isnan(x_raw));
x_raw(:,9:end)=[];
x_raw=reshape(x_raw,[],8);
%% Emotiv file
fs=x_raw.('sampFreq');
x_raw=x_raw.('data');
channel_i=[4:17];
channel_get=1;
% The ADC bit resolution
adc_res=2^14;
% The Input reference
v_max=8400;
x_raw=x_raw(:,channel_i);%*(v_max/adc_res);
x_raw=x_raw-4200;
%% Preprocess with notch and band pass
% Set up f_cut to filter
f_notch=50;
f_high=40;
f_low=0.16;
% Design notch filter
% notch_spec=fdesign.notch('N,F0,Q',6,(f_notch*2/fs),100); %
% % fdesign
% notch_filter=design(notch_spec);
wo=f_notch/(fs/2);
bw=wo/35;
[b,a] = iirnotch(wo,bw);
filtered_notch=zeros(size(x_raw));
filtered_lowpassed=zeros(size(x_raw));
filtered_highpassed=zeros(size(x_raw));
%% Apply filter
j=channel_get
%% Scale data
    x_raw(:,channel_i(j))=x_raw(:,channel_i(j));
%% Filter simple
%     for i=1:length(x_raw)/fs-1
%         filtered_notch((i-1)*30*fs+1:(i-1)*30*fs+30*fs,channel_i(j))=filter(notch_filter,x_raw((i-1)*30*fs+1:(i-1)*30*fs+30*fs,channel_i(j)));    
%     end
%     filtered_notch=filter(notch_filter,x_raw(:,channel_i(j)));
    filtered_lowpassed=lowpass(x_raw(:,channel_i(j)),f_high,fs,...
        'ImpulseResponse','iir');
    filtered_highpassed=highpass(filtered_lowpassed,f_low,fs,...
        'ImpulseResponse','iir');
 %% Preprocess with wavelet
%% Filter with wavlet
% Unchangeable: Don't change except you want to use another script
for j=1:length(channel_i)
    channel_name=['channel',num2str(channel_i(j))];
    filtered_notch=filter(b,a,x_raw(:,channel_i(j)));
    filtered_wavelet=get_waveletdata(filtered_notch,fs,[f_low f_high],'coif3');% sym9, db7, coif3 is suitable for eeg
    [filtered(:,j) EOG_estimate(:,j)]=MTfilt(filtered_wavelet,fs,0.97);
end
    %% Plot data
    % Selected channel
    j=1
    t=[1:length(filtered)];
    % Plot Raw data
    figure
    subplot(2,1,1)
    h(1)=plot(t,x_raw(t,channel_i(j)));
    title('Raw data')
    xlabel('t (s)')
    ylabel('Amplitude(\muV)');
%     axis([1 t(end) -150 150]);
%     axis([1 t(end) -150 150]);
    ax(1)=gca;
    % Plot Data after filter
    subplot(2,1,2)
    h(2)=plot(t,filtered(:,j));
    title('Data filtered')
    xlabel('t (s)')
    ylabel('Amplitude(\muV)')
%     axis([1 t(end) min(filtered(:,channel_i(j))) max(filtered(:,channel_i(j)))]);
    axis([1 t(30*fs) -150 150]);
    ax(2)=gca;
    % Plot EOG data
    figure
    h(3)=plot(t,EOG_estimate(:,j));
    title('Data EOG estimate')
    xlabel('t (s)')
    ylabel('Amplitude(\muV)')
    ax(3)=gca;
    axis([1 length(EOG_estimate) -400 400]);
    % Change axis label
    ax(1).XTickLabel=ax(1).XTick./fs;
    ax(2).XTickLabel=ax(2).XTick./fs;
    ax(3).XTickLabel=ax(3).XTick./fs;
    %% Plot with fft
    % FFT data
    [PSD,f]=fft_function(x_raw(:,channel_i(j)),fs,"Power");
    L=length(x_raw);
    % Plot data in time domain
    figure
    subplot(1,2,1);
    plot(f,x_raw(:,channel_i(j)))% Magic number 2
    title('Raw data')
    xlabel('Time (t)')
    ylabel('V (\muV)')
    axis([0 60 -100 100])
    % FFT for x_raw
    subplot(1,2,2);
    plot(f,PSD)% Magic number 2
    title('Power Spectrum Destiny of raw data')
    xlabel('f (Hz)')
    ylabel('PSD (\muV^2/Hz)')
    axis([0 60 0 50])
    %% Check data in frequency domain
    % FFT for x_raw
    [PSD,f]=fft_function(x_raw(:,channel_i(j)),fs,"Power");
    L=length(x_raw);
    figure
    subplot(2,1,1);
    plot(f,PSD)% Magic number 2
    title('Power Spectrum Destiny of raw data')
    xlabel('f (Hz)')
    ylabel('PSD (\muV^2/Hz)')
    axis([0 60 0 50])
    % FFT for data after filter
    [PSD,f]=fft_function(filtered(1:end),fs,"Power_Density");
    L=length(filtered(1:end));
    subplot(2,1,2);
    plot(f,PSD(:,1))% Magic number 2
    title('Power Spectrum Destiny of after filter')
    xlabel('f (Hz)')
    ylabel('PSD (\muV^2/Hz)')
    axis([0 50 0 100])
    %%
    [p,f]=pspectrum(x_raw(:,channel_i(j)),fs);
    figure;
    plot(f,p,'LineWidth',1.25,'color','b');
    axis([0 60 0 50])
    %% Check with power spectrogram
    figure
    [p,f,t]=pspectrum(filtered(:,channel_i(j)),fs,'spectrogram','FrequencyLimits',[0 70],'TimeResolution',30,'OverlapPercent',30);
%     norm=Normalize(p)./sum(p);
%     mesh(f,t,norm');
%     view(90,-90)   
