% The script file is calculating Calculating the Ratio of various EEG waves
% from PHYSIONET database
epoch_duration = input('How many seconds of an epoch? Value = ');%value of an epoch
total_epoch = fix(length(time_vector)/(fs*epoch_duration));
t=[0:fs*epoch_duration-1]/fs;%create the vector of time domain for Amplitude diagram
f=(0:fs*epoch_duration-1)*(1/epoch_duration);%create the vector of frequency for FFT diagram

%BorderValue=[1 4;4 8;8 13;13 35]; %declare border of various EEG waves
BorderValue=[0.5 2;4 8;8 13;13 35]; %declare border of various EEG waves for detect slow waves
for a=1:size(BorderValue,1)
    q=1;
    temp=[];
    for j=1:size(f',1)
    if f(j)>=BorderValue(a,1) && f(j)<BorderValue(a,2)%chi lay can trai cua BorderValue
        temp(q,1)=j;
        q=q+1;
    end
    end
    BorderAddress(a,1)=min(temp);
    BorderAddress(a,2)=max(temp);
end

    FFT_Filtered_data=[];
    Ratio_wave_data=[];
    for i=1:total_epoch
    temp_Wavelet_Filtered_data=FpzCz_Wavelet_Filtered(fix(fs*epoch_duration*(i-1)+1):fix(fs*epoch_duration*i));
    temp=fft_analyze(temp_Wavelet_Filtered_data,fs);
    FFT_Filtered_data=[FFT_Filtered_data;temp];
    P=temp;
    Psum=zeros(1,4);
    for k=1:size(Psum,2)%i chay theo tung vung 
        for l=1:size(f',1)% j chay theo tung gia tri tan so
            if l>=BorderAddress(k,1) && l<=BorderAddress(k,2)
              Psum(k)=Psum(k)+P(l);
            end
        end
    end
    for m=1:size(Psum,2)
        R(m)=Psum(m)/sum(Psum);
    end
        Ratio_wave_data=[Ratio_wave_data;R];
    end 
    assignin('base','FpzCz_FFT_Filtered',FFT_Filtered_data); %assign FFT Filtered channels to workspace
    assignin('base','FpzCz_Ratio_Power_waves',Ratio_wave_data);
    
    FFT_Filtered_data=[];
    Ratio_wave_data=[];
    for i=1:total_epoch
    temp_Wavelet_Filtered_data=PzOz_Wavelet_Filtered(fix(fs*epoch_duration*(i-1)+1):fix(fs*epoch_duration*i));
    temp=fft_analyze(temp_Wavelet_Filtered_data,fs);
    FFT_Filtered_data=[FFT_Filtered_data;temp];
    P=temp;
    Psum=zeros(1,4);
    for k=1:size(Psum,2)%i chay theo tung vung 
        for l=1:size(f',1)% j chay theo tung gia tri tan so
            if l>=BorderAddress(k,1) && l<=BorderAddress(k,2)
              Psum(k)=Psum(k)+P(l);
            end
        end
    end
    for m=1:size(Psum,2)
        R(m)=Psum(m)/sum(Psum);
    end
        Ratio_wave_data=[Ratio_wave_data;R];
    end 
    assignin('base','PzOz_FFT_Filtered',FFT_Filtered_data); %assign FFT Filtered channels to workspace
    assignin('base','PzOz_Ratio_Power_waves',Ratio_wave_data);