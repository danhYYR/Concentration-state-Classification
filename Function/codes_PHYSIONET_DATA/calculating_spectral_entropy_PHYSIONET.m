% The script file is Calculating Spectral Entropy of each Channel
% from PHYSIONET database

epoch_duration = input('How many seconds of an epoch? Value = ');%value of an epoch
total_epoch = fix(length(time_vector)/(fs*epoch_duration));
t=[0:fs*epoch_duration-1]/fs;%create the vector of time domain for Amplitude diagram
f=(0:fs*epoch_duration-1)*(1/epoch_duration);%create the vector of frequency for FFT diagram
Spectral_Entropy_1 =[];
Spectral_Entropy_2 =[];
Spectral_Entropy_mean_1=[];
Spectral_Entropy_mean_2=[];
Spectral_Entropy_total_1=[];
Spectral_Entropy_total_2=[];
for i=1:total_epoch
    temp1=PzOz_Wavelet_Filtered(fix(fs*epoch_duration*(i-1)+1):fix(fs*epoch_duration*i));
    temp2=FpzCz_Wavelet_Filtered(fix(fs*epoch_duration*(i-1)+1):fix(fs*epoch_duration*i));
    [se1,t1]=pentropy(temp1,fs);
    [se2,t2]=pentropy(temp2,fs);
    Spectral_Entropy_1=[Spectral_Entropy_1;se1'];
    Spectral_Entropy_mean_1=[Spectral_Entropy_mean_1;mean(se1)];
    Spectral_Entropy_total_1=[Spectral_Entropy_total_1 se1'];
    Spectral_Entropy_2=[Spectral_Entropy_2;se2'];
    Spectral_Entropy_mean_2=[Spectral_Entropy_mean_2;mean(se2)];
    Spectral_Entropy_total_2=[Spectral_Entropy_total_2 se2'];
end
assignin('base','PzOz_Spectral_Entropy_Value',Spectral_Entropy_1);
assignin('base','FpzCz_Spectral_Entropy_Value',Spectral_Entropy_2);
assignin('base','PzOz_Spectral_Entropy_Mean_Value',Spectral_Entropy_mean_1);
assignin('base','FpzCz_Spectral_Entropy_Mean_Value',Spectral_Entropy_mean_2);
assignin('base','PzOz_Spectral_Entropy_Value_Total',Spectral_Entropy_total_1);
assignin('base','FpzCz_Spectral_Entropy_Value_Total',Spectral_Entropy_total_2);
assignin('base','PzOz_Spectral_Entropy_Time',t1);
assignin('base','FpzCz_Spectral_Entropy_Time',t2);