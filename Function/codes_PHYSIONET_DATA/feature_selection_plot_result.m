figure
t=1:total_epoch;
stages=[];
for i=1:total_epoch
    temp=mean(STAGE(epoch_duration*(i-1)+1:epoch_duration*i));
    if temp == 1 % Stage N1
       temp=-1;
    elseif temp==2 % Stage N2
       temp=-2;
    elseif temp==3 % Stage N3
       temp=-3;
    elseif temp==4 % Stage REM
       temp=0; 
    else % Wake Stage
       temp=1;
    end
    stages=[stages;temp];
end
subplot(3,1,1)
plot(t,stages);
title('Actual N1 Stage');
ylim([-4 2])
xlim([1000 1800])
set(gca,'YTick',-3:-1:1)
set(gca,'YTickLabel',{'N3','N2','N1','REM','Wake'})
xlabel('Number of epoch (30s / epoch)')
ylabel('Stages')

% subplot(3,1,2)
% plot(t,FpzCz_Relative_Power_waves(:,1));
% hold on
% plot(t,FpzCz_Relative_Power_waves(:,2));
% hold on
% plot(t,FpzCz_Relative_Power_waves(:,3));
% hold on
% plot(t,FpzCz_Relative_Power_waves(:,4));
% hold on
% plot(t,FpzCz_Relative_Power_waves(:,5));
% hold on
% plot(t,FpzCz_Relative_Power_waves(:,6));
% hold on
% plot(t,FpzCz_Relative_Power_waves(:,7));
% hold on
% plot(t,FpzCz_Relative_Power_waves(:,8));
% hold on
% plot(t,FpzCz_Relative_Power_waves(:,9));
% hold on
% plot(t,FpzCz_Relative_Power_waves(:,10));
% hold on
% plot(t,FpzCz_Relative_Power_waves(:,11));
% hold on
% plot(t,FpzCz_Relative_Power_waves(:,12));
% hold on
% plot(t,FpzCz_Relative_Power_waves(:,13));
% hold on
% xlim([1000 1800])
% 
% subplot(3,1,3)
% plot(t,PzOz_Relative_Power_waves(:,1));
% hold on
% plot(t,PzOz_Relative_Power_waves(:,2));
% hold on
% plot(t,PzOz_Relative_Power_waves(:,3));
% hold on
% plot(t,PzOz_Relative_Power_waves(:,4));
% hold on
% plot(t,PzOz_Relative_Power_waves(:,5));
% hold on
% plot(t,PzOz_Relative_Power_waves(:,6));
% hold on
% plot(t,PzOz_Relative_Power_waves(:,7));
% hold on
% plot(t,PzOz_Relative_Power_waves(:,8));
% hold on
% plot(t,PzOz_Relative_Power_waves(:,9));
% hold on
% plot(t,PzOz_Relative_Power_waves(:,10));
% hold on
% plot(t,PzOz_Relative_Power_waves(:,11));
% hold on
% plot(t,PzOz_Relative_Power_waves(:,12));
% hold on
% plot(t,PzOz_Relative_Power_waves(:,13));
% hold on
% xlim([1000 1800])
% 
% figure
% subplot(3,1,1)
% plot(t,stages);
% title('Actual N1 Stage');
% ylim([-4 2])
% xlim([1000 1800])
% set(gca,'YTick',-3:-1:1)
% set(gca,'YTickLabel',{'N3','N2','N1','REM','Wake'})
% xlabel('Number of epoch (30s / epoch)')
% ylabel('Stages')
% 
% subplot(3,1,2)
% plot(t,FpzCz_Normalized_Power_waves(:,1));
% hold on
% plot(t,FpzCz_Normalized_Power_waves(:,2));
% hold on
% plot(t,FpzCz_Normalized_Power_waves(:,3));
% hold on
% plot(t,FpzCz_Normalized_Power_waves(:,4));
% hold on
% plot(t,FpzCz_Normalized_Power_waves(:,5));
% hold on
% plot(t,FpzCz_Normalized_Power_waves(:,6));
% hold on
% plot(t,FpzCz_Normalized_Power_waves(:,7));
% hold on
% plot(t,FpzCz_Normalized_Power_waves(:,8));
% hold on
% plot(t,FpzCz_Normalized_Power_waves(:,9));
% hold on
% plot(t,FpzCz_Normalized_Power_waves(:,10));
% hold on
% plot(t,FpzCz_Normalized_Power_waves(:,11));
% hold on
% plot(t,FpzCz_Normalized_Power_waves(:,12));
% hold on
% xlim([1000 1800])
% 
% subplot(3,1,3)
% plot(t,PzOz_Normalized_Power_waves(:,1));
% hold on
% plot(t,PzOz_Normalized_Power_waves(:,2));
% hold on
% plot(t,PzOz_Normalized_Power_waves(:,3));
% hold on
% plot(t,PzOz_Normalized_Power_waves(:,4));
% hold on
% plot(t,PzOz_Normalized_Power_waves(:,5));
% hold on
% plot(t,PzOz_Normalized_Power_waves(:,6));
% hold on
% plot(t,PzOz_Normalized_Power_waves(:,7));
% hold on
% plot(t,PzOz_Normalized_Power_waves(:,8));
% hold on
% plot(t,PzOz_Normalized_Power_waves(:,9));
% hold on
% plot(t,PzOz_Normalized_Power_waves(:,10));
% hold on
% plot(t,PzOz_Normalized_Power_waves(:,11));
% hold on
% plot(t,PzOz_Normalized_Power_waves(:,12));
% hold on
% xlim([1000 1800])
% 
% figure
% subplot(3,1,1)
% plot(t,stages);
% title('Actual N1 Stage');
% ylim([-4 2])
% xlim([1000 1800])
% set(gca,'YTick',-3:-1:1)
% set(gca,'YTickLabel',{'N3','N2','N1','REM','Wake'})
% xlabel('Number of epoch (30s / epoch)')
% ylabel('Stages')
% 
% subplot(3,1,2)
% plot(t,FpzCz_Average_Max_waves(:,1));
% hold on
% plot(t,FpzCz_Average_Max_waves(:,2));
% hold on
% plot(t,FpzCz_Average_Max_waves(:,3));
% hold on
% plot(t,FpzCz_Average_Max_waves(:,4));
% hold on
% plot(t,FpzCz_Average_Max_waves(:,5));
% hold on
% plot(t,FpzCz_Average_Max_waves(:,6));
% hold on
% plot(t,FpzCz_Average_Max_waves(:,7));
% hold on
% plot(t,FpzCz_Average_Max_waves(:,8));
% hold on
% xlim([1000 1800])
% 
% subplot(3,1,3)
% plot(t,PzOz_Average_Max_waves(:,1));
% hold on
% plot(t,PzOz_Average_Max_waves(:,2));
% hold on
% plot(t,PzOz_Average_Max_waves(:,3));
% hold on
% plot(t,PzOz_Average_Max_waves(:,4));
% hold on
% plot(t,PzOz_Average_Max_waves(:,5));
% hold on
% plot(t,PzOz_Average_Max_waves(:,6));
% hold on
% plot(t,PzOz_Average_Max_waves(:,7));
% hold on
% plot(t,PzOz_Average_Max_waves(:,8));
% hold on
% xlim([1000 1800])

subplot(3,1,2)
plot(PzOz_Spectral_Entropy_Mean_Value)
xlim([1000 1800])
subplot(3,1,3)
plot(FpzCz_Spectral_Entropy_Mean_Value)
xlim([1000 1800])