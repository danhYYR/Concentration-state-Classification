% This script find peaks of delta wave of each epoch

count_epoch_PzOz_delta=[];
count_epoch_FpzCz_delta=[];
for i=1:total_epoch
    temp_PzOz_delta = PzOz_Wavelet_Filtered(fix(fs*epoch_duration*(i-1)+1):fix(fs*epoch_duration*i));
    temp_count_epoch_PzOz_delta=0;
    temp_FpzCz_delta = FpzCz_Wavelet_Filtered(fix(fs*epoch_duration*(i-1)+1):fix(fs*epoch_duration*i));
    temp_count_epoch_FpzCz_delta=0;
    for j=1:30
        temp_epoch_PzOz_delta=temp_PzOz_delta(fix(fs*(j-1)+1):fix(fs*j));
        temp_epoch_FpzCz_delta=temp_FpzCz_delta(fix(fs*(j-1)+1):fix(fs*j));
        if max(temp_epoch_PzOz_delta)>= 25 %condition of 75uV
            temp_count_epoch_PzOz_delta=temp_count_epoch_PzOz_delta+1;
        else
            temp_count_epoch_PzOz_delta=temp_count_epoch_PzOz_delta;
        end
        if max(temp_epoch_FpzCz_delta)>= 25 %condition of 75uV
            temp_count_epoch_PzOz_delta=temp_count_epoch_FpzCz_delta+1;
        else
            temp_count_epoch_FpzCz_delta=temp_count_epoch_FpzCz_delta;
        end
    end
    count_epoch_PzOz_delta=[count_epoch_PzOz_delta;temp_count_epoch_PzOz_delta];
    count_epoch_FpzCz_delta=[count_epoch_FpzCz_delta;temp_count_epoch_FpzCz_delta];
end
figure;
plot(count_epoch_PzOz_delta,PzOz_Ratio_Power_waves(:,1),'ro')
hold on;
for i=1:total_epoch
    if stages(i)==-3
        plot(count_epoch_PzOz_delta(i),PzOz_Ratio_Power_waves(i,1),'bo');
        hold on;
    end
end
hold on;
predict_flag_new_PzOz_delta=zeros(total_epoch,1);
for i=1:total_epoch
    if ((flag_new_Delta_in_channel_PzOz(i)==1) & (count_epoch_PzOz_delta(i)==1))==1
        predict_flag_new_PzOz_delta(i)=1;
    end
end
hold off;

figure;
plot(count_epoch_PzOz_delta,PzOz_Ratio_Power_waves(:,1),'ro')
hold on;
predict_flag_new_PzOz_delta=zeros(total_epoch,1);
for i=1:total_epoch
    if ((flag_new_Delta_in_channel_PzOz(i)==1) & (count_epoch_PzOz_delta(i)==1))==1
        predict_flag_new_PzOz_delta(i)=1;
    end
end
for i=1:total_epoch
    if predict_flag_new_PzOz_delta(i)==1
        plot(count_epoch_PzOz_delta(i),PzOz_Ratio_Power_waves(i,1),'go');
        hold on;
    end
end        
hold off;

% figure;
% plot(count_epoch_FpzCz_delta,FpzCz_Ratio_Power_waves(:,1),'bo')
% hold on;
% for i=1:total_epoch
%     if stages(i)==-3
%         plot(count_epoch_FpzCz_delta(i),FpzCz_Ratio_Power_waves(i,1),'bo');
%         hold on;
%     end
% end
% hold off;