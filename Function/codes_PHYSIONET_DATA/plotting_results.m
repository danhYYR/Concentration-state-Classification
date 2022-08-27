% The script file is plotting results to diagrams

epoch_duration = input('How many seconds of an epoch? Value = ');%value of an epoch
disp(['The total number of epoch in data is ',num2str(fix(length(FpzCz)/(fs*epoch_duration)))]); %display total number of epoch
number_epoch=input('Please submit the epoch number that you want to show characteristics? \n epoch = ');%choose the value of #epoch
t=[0:fs*epoch_duration-1]/fs;%create the vector of time domain for Amplitude diagram
f=(0:fs*epoch_duration-1)*(1/epoch_duration);%create the vector of frequency for FFT diagram
temp_Original_data=FpzCz(fs*epoch_duration*(number_epoch-1)+1:fs*epoch_duration*number_epoch);%devide data to only 1 eppch
temp_Filtered_data=FpzCz_Filtered(fs*epoch_duration*(number_epoch-1)+1:fs*epoch_duration*number_epoch);%devide data to only 1 eppch
temp_Wavelet_Filtered_data=FpzCz_Wavelet_Filtered(fs*epoch_duration*(number_epoch-1)+1:fs*epoch_duration*number_epoch);%devide data to only 1 eppch
temp_FFT_Original_data=fft_analyze(temp_Original_data,fs);
temp_FFT_Filtered_data=fft_analyze(temp_Wavelet_Filtered_data,fs);
% Plotting Original Data & Filtered data

figure;
subplot(2,2,1)
    plot(t,temp_Original_data);
        xlabel('Time (s)')
        ylabel('Amplitude (uV)')
        title(['Original Signal in ','FpzCz',' Channel',' epoch # ',num2str(number_epoch)]);
        grid on;
        ylim([-300 300]);
    subplot(2,2,2)
    plot(t,temp_Wavelet_Filtered_data);
        xlabel('Time (s)')
        ylabel('Amplitude (uV)')
        title(['Filtered Signal in ','FpzCz',' Channel',' epoch # ',num2str(number_epoch)]);
        grid on;
        ylim([-300 300]);
    subplot(2,2,3)
    plot(f,temp_FFT_Original_data); 
        xlabel('Frequency (Hz)')
        ylabel('Power Density (uV^2/Hz)')
        title(['Power Spectrum Density of Original signal ','FpzCz',' Channel',' epoch # ',num2str(number_epoch)]);
        grid on;
        axis([0 100 0 100]);
    subplot(2,2,4)
    plot(f,temp_FFT_Filtered_data);
        xlabel('Frequency (Hz)')
        ylabel('Power Density (uV^2/Hz)')
        title(['Power Spectrum Density of Filtered signal in ','FpzCz',' Channel',' epoch # ',num2str(number_epoch)]);
        grid on;
        axis([0 100 0 100]);
        
figure;
temp_Original_data=PzOz(fs*epoch_duration*(number_epoch-1)+1:fs*epoch_duration*number_epoch);%devide data to only 1 eppch
temp_Filtered_data=PzOz_Filtered(fs*epoch_duration*(number_epoch-1)+1:fs*epoch_duration*number_epoch);%devide data to only 1 eppch
temp_Wavelet_Filtered_data=PzOz_Wavelet_Filtered(fs*epoch_duration*(number_epoch-1)+1:fs*epoch_duration*number_epoch);%devide data to only 1 eppch
temp_FFT_Original_data=fft_analyze(temp_Original_data,fs);
temp_FFT_Filtered_data=fft_analyze(temp_Wavelet_Filtered_data,fs);
% Plotting Original Data & Filtered data

subplot(2,2,1)
    plot(t,temp_Original_data);
        xlabel('Time (s)')
        ylabel('Amplitude (uV)')
        title(['Original Signal in ','PzOz',' Channel',' epoch # ',num2str(number_epoch)]);
        grid on;
        ylim([-300 300]);
    subplot(2,2,2)
    plot(t,temp_Wavelet_Filtered_data);
        xlabel('Time (s)')
        ylabel('Amplitude (uV)')
        title(['Filtered Signal in ','PzOz',' Channel',' epoch # ',num2str(number_epoch)]);
        grid on;
        ylim([-300 300]);
    subplot(2,2,3)
    plot(f,temp_FFT_Original_data); 
        xlabel('Frequency (Hz)')
        ylabel('Power Density (uV^2/Hz)')
        title(['Power Spectrum Density of Original signal ','PzOz',' Channel',' epoch # ',num2str(number_epoch)]);
        grid on;
        axis([0 100 0 100]);
    subplot(2,2,4)
    plot(f,temp_FFT_Filtered_data);
        xlabel('Frequency (Hz)')
        ylabel('Power Density (uV^2/Hz)')
        title(['Power Spectrum Density of Filtered signal in ','PzOz',' Channel',' epoch # ',num2str(number_epoch)]);
        grid on;
        axis([0 100 0 100]);