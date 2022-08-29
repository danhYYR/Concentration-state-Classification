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
for i=1:length(name)
    if iscell(name)
        path=[folder{i},'\',name{i}];
        disp(name{i});
    else
        path=[folder,'\',name];
        disp(name);
    end
    load(path);
    channel_i=6;
    %% Preprocess with notch and band pass
    % Set up f_cut to filter
    fs=500;
    f_notch=50;
    f_high=70;
    f_low=.5;
    % Design notch filter
    % notch_spec=fdesign.notch('N,F0,Q',6,(f_notch*2/fs),10); % use with
    % fdesign
    % notch_filter=design(notch_spec);
    wo=f_notch/(fs/2);
    bw=wo/35;
    [b,a] = iirnotch(wo,bw);
    %% Apply filter
    for j=1:channel_i
        channel_name=['channel',num2str(j)];
        if exist('x_concentration')
        % Concentration
            x_raw=x_concentration.(channel_name);
        end
        % Rest
        if exist('x_rest')
            x_raw=x_rest.(channel_name);
        end
        if ~isempty(find(isnan(x_raw)))
            i_nan=find(isnan(x_raw))
            x_raw(i_nan)=0;
        end
        %%
        filtered=filter(b,a,x_raw);
        filtered=lowpass(filtered,f_high,fs);
        filtered=highpass(filtered,f_low,fs);
        % filtered=bandpass(filtered,[0.5 70],fs);
         %% EOG remove reference
        [filtered EOG_estimate]=MTfilt(filtered,fs,0.97);
        filtered_save.(channel_name)=filtered;
        EOG_estimate_save.(channel_name)=EOG_estimate;
    end
    %% Plot data in time domain
    filtered=filtered_save.channel1;
    EOG_estimate=EOG_estimate_save.channel1;
    if exist('x_concentration')
           x_raw=x_concentration.channel1;
    end
    if exist('x_rest')
        x_raw=x_rest.channel1;
    end
    t=[1:length(filtered)];
    figure
    subplot(2,1,1)
    plot(t,x_raw(1:length(EOG_estimate)));
    title('Raw data')
    xlabel('t (s)')
    ylabel('Amplitude(\muV)')
    axis([1 length(EOG_estimate) -400 400]);
    subplot(2,1,2)
    plot(t,filtered(:,1));
    title('Data after filter')
    xlabel('t (s)')
    ylabel('Amplitude(\muV)')
    axis([1 length(EOG_estimate) -400 400]);
    figure
    plot(t,EOG_estimate(:,1));
    title('Data EOG estimate')
    xlabel('t (s)')
    ylabel('Amplitude(\muV)')
    axis([1 length(EOG_estimate) -400 400]);
    %% Plot with fft
    % FFT data
    [PSD,f]=fft_function(x_raw,fs,"Power_Density");
    L=length(x_raw);
    % Plot data in frequency domain
    figure
    subplot(2,1,1);
    plot(f,PSD(:,1))% Magic number 2
    title('Power Spectrum Destiny of raw data')
    xlabel('f (Hz)')
    ylabel('PSD (\muV^2/Hz)')
    axis([0 50 0 10])
    [PSD,f]=fft_function(filtered,fs,"Power_Density");
    L=length(filtered);
    subplot(2,1,2);
    plot(f,PSD(:,1))% Magic number 2
    title('Power Spectrum Destiny of after filter')
    xlabel('f (Hz)')
    ylabel('PSD (\muV^2/Hz)')
    axis([0 50 0 10])
    [p,f]=pspectrum(filtered,fs);
    figure;
    plot(f,Normalize(p),'LineWidth',1.25,'color','b');
    %% Check with power spectrogram
    norm=Normalize(filtered);
    figure
    pspectrum(norm(:,1),fs,'spectrogram','FrequencyLimits',[0 70],'TimeResolution',30,'OverlapPercent',0.7);
    %% Clear var
    %% Save data
    % This section uses to save file, if your file name concentration, you save
    % concetration var, if your file name rest, you save file rest
    % Please run this section twice to save concentration and rest
    if ~exist('path_save')
        folder_save=uigetdir;
    end
    if iscell(name)
        path_save=[folder_save,'\',name{i}];
    else
        path_save=[folder_save,'\',name];
    end
    if exist('x_concentration')
        % Concentration
        save([path_save,'.mat'],'filtered_save');
        save([folder_save,'\EOG\',name{i},'_EOG.mat'],'EOG_estimate_save');
        clear x_concentration
    end
    % Rest
    if exist('x_rest')
        save([path_save,'.mat'],'filtered_save');
        save([path_save,'_EOG.mat'],'EOG_estimate_save');
        close all;
        clear x_rest;
    end
    if ~iscell(name)
        break;
    end
end