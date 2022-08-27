%%% This code using to compute deflection angle
% Deflection Angle = arctan(m)
% These script compute m

N = 0.2*fs;% example if fs=500, N must equal=1, N=0.2*500Hz = 1 seconds
time_temp_EOG=linspace(0,0.1*double(fs));
m_EOG=[];
d = fdesign.bandpass('n,f3dB1,f3dB2', 4, 1, 5, fs);
Hd=design(d,'butter');
EOG_filtered=[];
for i=1:total_epoch
    temp_EOG_filtered=filter(Hd,EOG(fix(fs*epoch_duration*(i-1)+1):fix(fs*epoch_duration*i)));
    EOG_filtered=[EOG_filtered;temp_EOG_filtered];
end
for i=1:length(all_total_CREM)
    temp_xy_EOG=[];
    temp_x_EOG=[];
    temp_y_EOG=[];
    temp_x2_EOG=[];
    
    temp_EOG=EOG_filtered((all_total_CREM(i,3)-0.1*int64(fs)+1):(all_total_CREM(i,3)+0.1*int64(fs)-1));
        
    for j=1:N
        temp_xy_EOG = [temp_xy_EOG,time_temp_EOG(j)*temp_EOG_filtered(j)];
        temp_x_EOG = [temp_x_EOG,time_temp_EOG(j)];
        temp_y_EOG = [temp_y_EOG,temp_EOG_filtered(j)];
        temp_x2_EOG = [temp_x2_EOG,time_temp_EOG(j)^2];
    end
    temp_m_EOG=-(N*sum(temp_xy_EOG)-sum(temp_x_EOG)*sum(temp_y_EOG))/(N*sum(temp_x2_EOG)-(sum(temp_x_EOG)^2));
    m_EOG=[m_EOG temp_m_EOG];
end
EOG_angle=abs(atan(double(m_EOG'))*180/pi);

flag_valid_REM=[];
for i=1:length(all_total_CREM)
	if EOG_angle(i) > 45
		temp_flag_valid_REM = 1;
	else
		temp_flag_valid_REM = 0;
    end
    flag_valid_REM=[flag_valid_REM;temp_flag_valid_REM];
end
all_total_CREM=[all_total_CREM EOG_angle flag_valid_REM];
    