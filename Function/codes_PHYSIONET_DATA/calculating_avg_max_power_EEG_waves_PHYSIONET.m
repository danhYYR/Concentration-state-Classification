% Calculate Average and Maximum Power of each channel
% Number of rows = number of epochs
% Column No.1: Delta Average
% Column No.2: Theta Average
% Column No.3: Alpha Average
% Column No.4: Beta Average
% Column No.5: Delta Maximum Power 
% Column No.6: Theta Maximum Power
% Column No.7: Alpha Maximum Power
% Column No.8: Beta Maximum Power
% Definition of each waves in below
% Delta [0 3.4) Hz
% Theta [3.4 7.4) Hz
% Alpha [7.4 12.4) Hz
% Beta [12.4 35) Hz
% The script file is Calculating the Average and Max value of Power in various EEG waves
% from PHYSIONET database
epoch_duration = input('How many seconds of an epoch? Value = ');%value of an epoch
total_epoch = fix(length(time_vector)/(fs*epoch_duration));
t=[0:fs*epoch_duration-1]/fs;%create the vector of time domain for Amplitude diagram
f=(0:fs*epoch_duration-1)*(1/epoch_duration);%create the vector of frequency for FFT diagram

BorderValue=[0 3.4;3.4 7.4;7.4 12.4;12.4 35]; %declare border of various EEG waves

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

Average_Max_wave_data=[];
for i=1:total_epoch
    temp=FpzCz_FFT_Filtered(fix(fs*epoch_duration*(i-1)+1):fix(fs*epoch_duration*i));
    avg_temp1=[];
    avg_temp2=[];
    avg_temp3=[];
    avg_temp4=[];
    for j=1:size(temp)
        if (j>=BorderAddress(1,1)) && (j<=BorderAddress(1,2))
            avg_temp1=[avg_temp1;temp(j)]; % Gan gia tri Delta epoch thu i
        elseif (j>=BorderAddress(2,1)) && (j<=BorderAddress(2,2))
            avg_temp2=[avg_temp2;temp(j)]; % Gan gia tri Theta epoch thu i
        elseif (j>=BorderAddress(3,1)) && (j<=BorderAddress(3,2))
            avg_temp3=[avg_temp3;temp(j)]; % Gan gia tri Alpha epoch thu i  
        elseif (j>=BorderAddress(4,1)) && (j<=BorderAddress(4,2))
            avg_temp4=[avg_temp4;temp(j)]; % Gan gia tri Beta epoch thu i 
        end
    end
        A1=mean(avg_temp1); % Col No.1: Delta Average
        A2=mean(avg_temp2); % Col No.2: Theta Average
        A3=mean(avg_temp3); % Col No.3: Alpha Average
        A4=mean(avg_temp4); % Col No.4: Beta Average
        M1=max(avg_temp1); % Col No.5: Delta Maximum Power
        M2=max(avg_temp2); % Col No.6: Theta Maximum Power
        M3=max(avg_temp3); % Col No.7: Alpha Maximum Power
        M4=max(avg_temp4); % Col No.8: Beta Maximum Power
   Average_Max_wave_data=[Average_Max_wave_data;A1 A2 A3 A4 M1 M2 M3 M4];
end
assignin('base','FpzCz_Average_Max_waves',Average_Max_wave_data);

Average_Max_wave_data=[];
for i=1:total_epoch
    temp=PzOz_FFT_Filtered(fix(fs*epoch_duration*(i-1)+1):fix(fs*epoch_duration*i));
    avg_temp1=[];
    avg_temp2=[];
    avg_temp3=[];
    avg_temp4=[];
    for j=1:size(temp)
        if (j>=BorderAddress(1,1)) && (j<=BorderAddress(1,2))
            avg_temp1=[avg_temp1;temp(j)]; % Gan gia tri Delta epoch thu i
        elseif (j>=BorderAddress(2,1)) && (j<=BorderAddress(2,2))
            avg_temp2=[avg_temp2;temp(j)]; % Gan gia tri Theta epoch thu i
        elseif (j>=BorderAddress(3,1)) && (j<=BorderAddress(3,2))
            avg_temp3=[avg_temp3;temp(j)]; % Gan gia tri Alpha epoch thu i  
        elseif (j>=BorderAddress(4,1)) && (j<=BorderAddress(4,2))
            avg_temp4=[avg_temp4;temp(j)]; % Gan gia tri Beta epoch thu i 
        end
    end
        A1=mean(avg_temp1); % Col No.1: Delta Average
        A2=mean(avg_temp2); % Col No.2: Theta Average
        A3=mean(avg_temp3); % Col No.3: Alpha Average
        A4=mean(avg_temp4); % Col No.4: Beta Average
        M1=max(avg_temp1); % Col No.5: Delta Maximum Power
        M2=max(avg_temp2); % Col No.6: Theta Maximum Power
        M3=max(avg_temp3); % Col No.7: Alpha Maximum Power
        M4=max(avg_temp4); % Col No.8: Beta Maximum Power
   Average_Max_wave_data=[Average_Max_wave_data;A1 A2 A3 A4 M1 M2 M3 M4]; 
end
assignin('base','PzOz_Average_Max_waves',Average_Max_wave_data);
  
        