%test code detect waves
Channel_Name = input('Enter the Channel name that you want to analysis = ')
Ratio_wave_Name=strcat(Channel_Name,'_Ratio_Power_waves');
temp_Ratio_wave_data=eval(Ratio_wave_Name);
flag_Alpha_Name=strcat('flag_Alpha_in_channel_',Channel_Name);
flag_Beta_Name=strcat('flag_Beta_in_channel_',Channel_Name);
flag_Theta_Name=strcat('flag_Theta_in_channel_',Channel_Name);
flag_Delta_Name=strcat('flag_Delta_in_channel_',Channel_Name);
flag_new_Delta_Name=strcat('flag_new_Delta_in_channel_',Channel_Name);
flag_Alpha = [];
flag_Beta = [];
flag_Theta = [];
flag_Delta = [];
flag_new_Delta = [];
Alpha_thresholding=func_threshold(temp_Ratio_wave_data(:,3))
Beta_thresholding=func_threshold(temp_Ratio_wave_data(:,4))
Theta_thresholding=func_threshold(temp_Ratio_wave_data(:,2))
Delta_thresholding=func_threshold(temp_Ratio_wave_data(:,1))
    for i=1:total_epoch
        if temp_Ratio_wave_data(i,3) >= Alpha_thresholding%0.3 %detect Alpha wave
            temp_flag_Alpha = 1;
        else
            temp_flag_Alpha = 0;
        end
        if temp_Ratio_wave_data(i,4) >= Beta_thresholding %0.3 %detect Beta wave
            temp_flag_Beta = 1;
        else
            temp_flag_Beta = 0;
        end
        if temp_Ratio_wave_data(i,2) >= Theta_thresholding %0.15 %detect Theta wave
            temp_flag_Theta = 1;
        else
            temp_flag_Theta = 0;
        end
        if temp_Ratio_wave_data(i,1) >= Delta_thresholding + (1-Delta_thresholding)/2 %high delta power
            temp_flag_Delta = 1;
            temp_flag_new_Delta =0;
        elseif temp_Ratio_wave_data(i,1) <= Delta_thresholding - (1-Delta_thresholding)/2 %low delta power
            temp_flag_new_Delta =0;
        else
            temp_flag_Delta = 0;
            temp_flag_new_Delta =1;
        end
        flag_Alpha = [flag_Alpha , temp_flag_Alpha];
        flag_Beta = [flag_Beta , temp_flag_Beta];
        flag_Theta = [flag_Theta ,temp_flag_Theta];
        flag_Delta = [flag_Delta , temp_flag_Delta];
        flag_new_Delta = [flag_new_Delta , temp_flag_new_Delta];
    end
Value_Alpha = sum (flag_Alpha);
Value_Beta = sum (flag_Beta);
Value_Theta = sum (flag_Theta);
Value_Delta = sum (flag_Delta);
Value_new_Delta = sum (flag_new_Delta);
disp(['There are',' ',num2str(Value_Alpha),' ','epochs appear Alpha waves in Channel ',Channel_Name]);
disp(['There are',' ',num2str(Value_Beta),' ','epochs appear Beta waves in Channel ',Channel_Name]);
disp(['There are',' ',num2str(Value_Theta),' ','epochs appear Theta waves in Channel ',Channel_Name]);
disp(['There are',' ',num2str(Value_Delta),' ','epochs appear Delta waves in Channel ',Channel_Name]);
disp(['There are',' ',num2str(Value_new_Delta),' ','epochs appear NEW Delta waves in Channel ',Channel_Name]);
assignin('base',flag_Alpha_Name,flag_Alpha);
assignin('base',flag_Beta_Name,flag_Beta);
assignin('base',flag_Theta_Name,flag_Theta);
assignin('base',flag_Delta_Name,flag_Delta);
assignin('base',flag_new_Delta_Name,flag_new_Delta);