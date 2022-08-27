% The script file is analyzing data from PHYSIONET database by using wavelet transform function

%Using Notch filter
F0_notch = 50*2/fs; % Quy ve tan so chuan hoa
Fc_lowpass = 35*2/fs; % Quy ve tan so chuan hoa
Fc_highpass = 0.5*2/fs; % Quy ve tan so chuan hoa

%Design Notch filter
d_notch = fdesign.notch('N,F0,Q',6,F0_notch,10,fs);
Hd_notch = design(d_notch);

%Design FIR lowpass filter
d_lowpass = fdesign.lowpass('N,Fc',10,Fc_lowpass);
Hd_lowpass = design(d_lowpass);

%Design FIR highpass filter
d_highpass = fdesign.highpass('N,Fc',10,Fc_highpass);
Hd_highpass = design(d_highpass);

%Appy all filter to EEG data
FpzCz_Filtered = filter(Hd_lowpass,filter(Hd_highpass,filter(Hd_notch,FpzCz)));
PzOz_Filtered = filter(Hd_lowpass,filter(Hd_highpass,filter(Hd_notch,PzOz)));

%assign Wavelet Filtered channels to workspace with Min-Max and db7
assignin('base','FpzCz_Wavelet_Filtered',wavelet_analyze(FpzCz_Filtered,2,9,'sym9'));%Note: sym9, db7, coif3 are the best mother wavelet of EEG signal
assignin('base','PzOz_Wavelet_Filtered',wavelet_analyze(PzOz_Filtered,2,9,'sym9'));%Note: sym9, db7, coif3 are the best mother wavelet of EEG signal

%Design filter for EMG data include offset value
fco=20;%frequency cut off value
[b,a]=butter(2,fco*0.0125/(fs_EMG/2));%fnyq=fs/2 using Butterword filter 2 times 6 other
EMG_Filtered=filtfilt(b,a,(EMG-mean(EMG)));%use abs(EMG-mean(EMG) if use 'Rectified' data of EMG
