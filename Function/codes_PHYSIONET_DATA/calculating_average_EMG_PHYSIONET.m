% The script file is calculating the average EMG from PHYSIONET database
epoch_duration = input('How many seconds of an epoch? Value = ');%value of an epoch
EMG_Average=[];
EMG_Power=[];
for i=1:total_epoch
    temp_EMG_Average=rms(EMG_Filtered(fs_EMG*epoch_duration*(i-1)+1:fs_EMG*epoch_duration*i));
    temp_EMG_Power=sum(fft_analyze(EMG_Filtered(fs_EMG*epoch_duration*(i-1)+1:fs_EMG*epoch_duration*i),fs_EMG));
    EMG_Average=[EMG_Average;temp_EMG_Average];
    EMG_Power=[EMG_Power;temp_EMG_Power];
 end
 assignin('base','EMG_Average',EMG_Average);
 assignin('base','EMG_Power',EMG_Power);
 EMG_Average_Thresholding=func_threshold(EMG_Average)
 EMG_Power_Thresholding=func_threshold(EMG_Power)
 
flag_EMG_Average_high=[];
flag_EMG_Power_high=[];
for i=1:total_epoch
        if EMG_Average(i) >= (EMG_Average_Thresholding + EMG_Average_Thresholding/4) %detect high value of average EMG
            temp_EMG_Average_high = 1;
        elseif EMG_Average(i) <= (EMG_Average_Thresholding - EMG_Average_Thresholding/2) %detect low value of average EMG
            temp_EMG_Average_high = -1;
        else
            temp_EMG_Average_high = 0;
        end
        if EMG_Power(i) >= (EMG_Power_Thresholding + EMG_Power_Thresholding/4) %detect high value of power EMG
            temp_EMG_Power_high = 1;
        elseif EMG_Power(i) <= (EMG_Power_Thresholding - EMG_Power_Thresholding/2) %detect low value of average EMG
            temp_EMG_Power_high = -1;
        else
            temp_EMG_Power_high = 0;
        end
        flag_EMG_Average_high = [flag_EMG_Average_high , temp_EMG_Average_high];
        flag_EMG_Power_high = [flag_EMG_Power_high , temp_EMG_Power_high];
    end
assignin('base','flag_EMG_Average_high',flag_EMG_Average_high);
assignin('base','flag_EMG_Power_high',flag_EMG_Power_high);

