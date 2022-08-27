% The script file is automatic scoring sleep stage base on AASM rules (use PHYSIONET database)
%+ Step 1: Loading data. Open *.edf file format (convert to 2 files *.csv
%(1Hz ==> EMG & 100Hz ==> 2 channels EEG + 1 channel EOG)
%+ Step 2: Pre-processing ==> Applying the filters to EEG & EMG signal 
%(EOG filter will be apply in next step)
%+ Step 3: using automatic thresholding to detect and flag ON/ OFF signal including EEG waves band, Average EMG, Power EMG
%+ Step 4: Extract microwave (include K-complex base on 14 characteristics)
%+ Step 5: Find and extract SEM (Slow Eye Movements)
%+ Step 6: Find and extract CREM (Candidate of Rapid Eye Movements)
%+ Step 7: Predicting N1 Stage, N2 Stage, N3 Stage, REM Stage and W Stage
%+ Step 8: Statistics and Plotting results

epoch_duration = input('How many seconds of an epoch? Value = ');%value of an epoch
total_epoch = fix(length(time_vector)/(fs*epoch_duration));
stages=[];
figure;
t=1:total_epoch;

%subplot(6,1,1)

% subplot(6,1,1)
% plot(t,flag_N1_Stage);
% title('Pridict N1 Stage');
% ylim([-1 2]);
% xlim([0 total_epoch]);
% %xlim([1000 1800]);
% set(gca,'YTick',-1:1:2)
% set(gca,'YTickLabel',{'','Other','N1',''})
% ylabel('Stages')

% subplot(6,1,2)
% plot(t,flag_Microwaves_in_total_channels);
% title('The Prediction of N2 Stage');
% ylim([-1 2]);
% xlim([0 total_epoch]);
% %xlim([1000 1800]);
% set(gca,'YTick',-1:1:2)
% set(gca,'YTickLabel',{'','Other','N2',''})
% xlabel('Number of epoch (30s / epoch)')
% ylabel('Stages')

subplot(4,1,1)
plot(t,flag_N3_Stage);
title('The Prediction of N3 Stage');
xlim([0 total_epoch]);
%xlim([1000 1800]);
ylim([-1 2]);
set(gca,'YTick',-1:1:2)
set(gca,'YTickLabel',{'','None','Predict N3',''})
ylabel('Stages')

subplot(4,1,2)
plot(t,flag_predict_REM);
title('The Prediction of REM Stage');
xlim([0 total_epoch]);
%xlim([1000 1800]);
ylim([-1 2]);
set(gca,'YTick',-1:1:2)
set(gca,'YTickLabel',{'','Other','REM',''})
ylabel('Stages')

predict_hypnogram=[];
for i=1:total_epoch
    if ((flag_predict_REM(i)==1) && (flag_N3_Stage(i)==0))==1
        predict_hypnogram(i)=0; % Stage REM
    elseif ((flag_predict_REM(i)==1) && (flag_N3_Stage(i)==1))==1
        predict_hypnogram(i)=1; %Others Stage
    elseif ((flag_predict_REM(i)==0) && (flag_N3_Stage(i)==1))==1
        predict_hypnogram(i)=-3; %Stage N3
    elseif ((flag_predict_REM(i)==0) && (flag_N3_Stage(i)==0))==1
        predict_hypnogram(i)=1; %Others Stage
    else
        predict_hypnogram(i)=1; %Others Stage
    end
end

%Smoothing Stages
FINAL_STAGES_temp=predict_hypnogram;
Stages=predict_hypnogram;

for i=2:1:length(Stages)-4
    if Stages(i)==1 %Wakefulness Stage 1
        if Stages(i-1)==-3 & Stages(i+1)==-3
            FINAL_STAGES_temp(i)=-3;
        elseif Stages(i-1)==0 & Stages(i+1)==0
            FINAL_STAGES_temp(i)=0;
        else
            FINAL_STAGES_temp(i)=1;
        end
    elseif  Stages(i)==0 % REM stage 0
        if Stages(i-1)==1 & Stages(i+1)==1
            FINAL_STAGES_temp(i)=1;
        elseif Stages(i-1)==-3 & Stages(i+1)==-3
            FINAL_STAGES_temp(i)=-3;
        else
            FINAL_STAGES_temp(i)=0;
        end
    elseif  Stages(i)==-3 % N3 - Non-REM stage -3
        if Stages(i-1)==1 && Stages(i+1)==1
            FINAL_STAGES_temp(i)=1;
        elseif Stages(i-1)==0 && Stages(i+1)==0
            FINAL_STAGES_temp(i)=0;
        else
            FINAL_STAGES_temp(i)=-3;
        end
    else
        FINAL_STAGES_temp(i)=1;
    end
end

subplot(4,1,3)
for i=1:length(FINAL_STAGES_temp)
     tv(i*2-1:i*2)=[(i-1) i];
     gv(i*2-1:i*2)=FINAL_STAGES_temp(i);
end
plot(tv,gv,'Linewidth',3);
%plot(t,FINAL_STAGES_temp,'Linewidth',3);
yticks([-3,0,1])
yticklabels({'N3','REM','Others Stage'})
xlabel('# epoch (30s / epoch)');
ylabel('Stages');
xlim([0 total_epoch]);
%xlim([1000 1700]);
ylim([-4 2]);
title(['The hypnogram of Prediction']);
grid on

temp_stages=[];
for i=1:total_epoch
    temp=mean(STAGE(epoch_duration*(i-1)+1:epoch_duration*i));
    if temp == 1 % Stage N1
       temp_stages=1;% Other Stages
    elseif temp==2 % Stage N2
       temp_stages=1;% Other Stages
    elseif temp==3 % Stage N3
       temp_stages=-3;
    elseif temp==4 % Stage REM
       temp_stages=0; 
    else % Wake Stage
       temp_stages=1;% Other Stages
    end
    stages=[stages;temp_stages];
end

% Plot the hypnogram of manual scoring by expert
subplot(4,1,4)
for i=1:length(stages)
     tv(i*2-1:i*2)=[(i-1) i];
     gv(i*2-1:i*2)=stages(i);
end
plot(tv,gv,'Linewidth',3);
%plot(t,stages,'Linewidth',3);
yticks([-3,0,1])
yticklabels({'N3','REM','Others Stage'})
xlabel('# epoch (30s / epoch)');
ylabel('Stages');
xlim([0 total_epoch]);
%xlim([1000 1700]);
ylim([-4 2]);
title(['The hypnogram of manual scoring by expert']);
grid on

% These script in below calculate some statistical parameters

g1=[];
temp_g1=[];
for i=1:total_epoch
    if stages(i)==0% Stage REM
        temp_g1='REM'; 
    elseif stages(i)==-3% N3 Stage
        temp_g1='N3';
    elseif stages(i)==1% Others Stages
        temp_g1='Others';
    end
    g1=[g1;{temp_g1}];
end

g2=[];
temp_g2=[];
for i=1:total_epoch
    if FINAL_STAGES_temp(i)==0% Stage REM
        temp_g2='REM'; 
    elseif FINAL_STAGES_temp(i)==-3% N3 Stage
        temp_g2='N3';
    elseif FINAL_STAGES_temp(i)==1% Others Stages
        temp_g2='Others';
    end
    g2=[g2;{temp_g2}];
end

%g1=g1(1000:1700);
%g2=g2(1000:1700);
confusion_matrix = confusionmat(g1,g2);
figure;
cm = confusionchart(g2,g1, ...
    'ColumnSummary','column-normalized', ...
    'RowSummary','row-normalized');


% for i=1:total_epoch
%     temp=mean(STAGE(epoch_duration*(i-1)+1:epoch_duration*i));
%     if temp == 1 % Stage N1
%        temp=-1;
%     elseif temp==2 % Stage N2
%        temp=-2;
%     elseif temp==3 % Stage N3
%        temp=-3;
%     elseif temp==4 % Stage REM
%        temp=0; 
%     else % Wake Stage
%        temp=1;
%     end
%     stages=[stages;temp];
% end
% 
% 
% % Plot the hypnogram of manual scoring by expert
% subplot(6,1,6)
% for i=1:length(stages)
%      tv(i*2-1:i*2)=[(i-1) i];
%      gv(i*2-1:i*2)=stages(i);
% end
% plot(tv,gv,'Linewidth',3);
% yticks([-3,-2,-1,0,1])
% yticklabels({'N3','N2','N1','REM','Wake'})
% xlabel('# epoch (30s / epoch)');
% ylabel('Stages');
% %xlim([0 total_epoch]);
% xlim([1000 1800]);
% ylim([-4 2]);
% title(['The hypnogram of manual scoring by expert']);
% grid on

% %Smoothing Stages
% FINAL_STAGES_temp=Stages;
% 
% for i=2:1:length(Stages)-4
%     if Stages(i)==2 %Wakefulness Stage
%         if Stages(i-1)==1 & Stages(i+1)==1
%             FINAL_STAGES_temp(i)=1;
%         elseif Stages(i-1)==0 & Stages(i+1)==0
%             FINAL_STAGES_temp(i)=0;
%         elseif Stages(i-1)==-1 & Stages(i+1)==-1
%             FINAL_STAGES_temp(i)=-1;
%         elseif Stages(i-1)==-2 & Stages(i+1)==-2
%             FINAL_STAGES_temp(i)=-2;
%         else
%             FINAL_STAGES_temp(i)=2;
%         end
%     elseif  Stages(i)==1 % REM stage
%         if Stages(i-1)==2 & Stages(i+1)==2
%             FINAL_STAGES_temp(i)=2;
%         elseif Stages(i-1)==0 & Stages(i+1)==0
%             FINAL_STAGES_temp(i)=0;
%         elseif Stages(i-1)==-1 & Stages(i+1)==-1
%             FINAL_STAGES_temp(i)=-1;
%         elseif Stages(i-1)==-2 & Stages(i+1)==-2
%             FINAL_STAGES_temp(i)=-2;
%         else
%             if (Stages(i+1)==1)&(Stages(i+2)==1)&(Stages(i+3)==1)&(Stages(i+4)==1)
%                 FINAL_STAGES_temp(i)=1;
%             else
%                 FINAL_STAGES_temp(i)=FINAL_STAGES_temp(i-1);
%             end
%         end
%     elseif  Stages(i)==0 % N1 - Non-REM stage
%         if Stages(i-1)==2 & Stages(i+1)==2
%             FINAL_STAGES_temp(i)=2;
%         elseif Stages(i-1)==1 & Stages(i+1)==1
%             FINAL_STAGES_temp(i)=1;
%         elseif Stages(i-1)==-1 & Stages(i+1)==-1
%             FINAL_STAGES_temp(i)=0;% chu y sua code dong nay
%         elseif Stages(i-1)==-2 & Stages(i+1)==-2
%             FINAL_STAGES_temp(i)=-2;
%         else
%             FINAL_STAGES_temp(i)=0;
%         end
%     elseif  Stages(i)==-1% N2 - Non-REM stage
%         if Stages(i-1)==2 & Stages(i+1)==2
%             FINAL_STAGES_temp(i)=2;
%         elseif Stages(i-1)==1 & Stages(i+1)==1
%             FINAL_STAGES_temp(i)=1;
%         elseif Stages(i-1)==0 & Stages(i+1)==0
%             FINAL_STAGES_temp(i)=0;
%         elseif Stages(i-1)==-2 & Stages(i+1)==-2
%             FINAL_STAGES_temp(i)=-2;
%         else
%             if (Stages(i+1)==-1)&&(Stages(i+2)==-1)
%                 FINAL_STAGES_temp(i)=-1;
%             else
%                 FINAL_STAGES_temp(i)=FINAL_STAGES_temp(i-1);
%             end
%         end
%     elseif  Stages(i)==-2 % N3 - Non-REM stage
%         if Stages(i-1)==2 && Stages(i+1)==2
%             FINAL_STAGES_temp(i)=2;
%         elseif Stages(i-1)==1 && Stages(i+1)==1
%             FINAL_STAGES_temp(i)=1;
%         elseif Stages(i-1)==0 && Stages(i+1)==0
%             FINAL_STAGES_temp(i)=0;
%         elseif Stages(i-1)==-1 && Stages(i+1)==-1
%             FINAL_STAGES_temp(i)=-1;
%         else
%             FINAL_STAGES_temp(i)=-2;
%         end
%     end
% end
% 
% 
% 
% %%% Loc du lieu hien thi lai lan nua
% FINAL_STAGES=FINAL_STAGES_temp;
% for i=2:1:length(FINAL_STAGES_temp)-1
%         if FINAL_STAGES_temp(i)==2 %Wakefulness Stage
%         if FINAL_STAGES_temp(i-1)==1 && FINAL_STAGES_temp(i+1)==1
%             FINAL_STAGES(i)=1;
%         elseif FINAL_STAGES_temp(i-1)==0 && FINAL_STAGES_temp(i+1)==0
%             FINAL_STAGES(i)=0;
%         elseif FINAL_STAGES_temp(i-1)==-1 && FINAL_STAGES_temp(i+1)==-1
%             FINAL_STAGES(i)=-1;
%         elseif FINAL_STAGES_temp(i-1)==-2 && FINAL_STAGES_temp(i+1)==-2
%             FINAL_STAGES(i)=-2;
%         else
%             FINAL_STAGES(i)=2;
%         end
%     elseif  FINAL_STAGES_temp(i)==1 % REM stage
%         if FINAL_STAGES_temp(i-1)==2 && FINAL_STAGES_temp(i+1)==2
%             FINAL_STAGES(i)=2;
%         elseif FINAL_STAGES_temp(i-1)==0 && FINAL_STAGES_temp(i+1)==0
%             FINAL_STAGES(i)=0;
%         elseif FINAL_STAGES_temp(i-1)==-1 && FINAL_STAGES_temp(i+1)==-1
%             FINAL_STAGES(i)=-1;
%         elseif FINAL_STAGES_temp(i-1)==-2 && FINAL_STAGES_temp(i+1)==-2
%             FINAL_STAGES(i)=-2;
%         else
%             FINAL_STAGES(i)=1;
%         end
%     elseif  FINAL_STAGES_temp(i)==0 % N1 - Non-REM stage
%         if FINAL_STAGES_temp(i-1)==2 && FINAL_STAGES_temp(i+1)==2
%             FINAL_STAGES(i)=2;
%         elseif FINAL_STAGES_temp(i-1)==1 && FINAL_STAGES_temp(i+1)==1
%             FINAL_STAGES(i)=1;
%         elseif FINAL_STAGES_temp(i-1)==-1 && FINAL_STAGES_temp(i+1)==-1
%             FINAL_STAGES(i)=-1;
%         elseif FINAL_STAGES_temp(i-1)==-2 && FINAL_STAGES_temp(i+1)==-2
%             FINAL_STAGES(i)=-2;
%         else
%             FINAL_STAGES(i)=0;
%         end
%     elseif  FINAL_STAGES_temp(i)==-1% N2 - Non-REM stage
%         if FINAL_STAGES_temp(i-1)==2 && FINAL_STAGES_temp(i+1)==2
%             FINAL_STAGES(i)=2;
%         elseif FINAL_STAGES_temp(i-1)==1 && FINAL_STAGES_temp(i+1)==1
%             FINAL_STAGES(i)=1;
%         elseif FINAL_STAGES_temp(i-1)==0 && FINAL_STAGES_temp(i+1)==0
%             FINAL_STAGES(i)=0;
%         elseif FINAL_STAGES_temp(i-1)==-2 && FINAL_STAGES_temp(i+1)==-2
%             FINAL_STAGES(i)=-2;
%         else
%             FINAL_STAGES(i)=-1;
%         end
%     elseif  FINAL_STAGES_temp(i)==-2 % N3 - Non-REM stage
%         if FINAL_STAGES_temp(i-1)==2 && FINAL_STAGES_temp(i+1)==2
%             FINAL_STAGES(i)=2;
%         elseif FINAL_STAGES_temp(i-1)==1 && FINAL_STAGES_temp(i+1)==1
%             FINAL_STAGES(i)=1;
%         elseif FINAL_STAGES_temp(i-1)==0 && FINAL_STAGES_temp(i+1)==0
%             FINAL_STAGES(i)=0;
%         elseif FINAL_STAGES_temp(i-1)==-1 && FINAL_STAGES_temp(i+1)==-1
%             FINAL_STAGES(i)=-1;
%         else
%             FINAL_STAGES(i)=-2;
%         end
%     end
% end


% Plot the hypnogram
% for i=1:length(FINAL_STAGES)
%      tv(i*2-1:i*2)=[(i-1) i];
%      gv(i*2-1:i*2)=FINAL_STAGES(i);
%  end
% plot(tv,gv,'Linewidth',3);
% yticks([-2,-1,0,1,2])
% yticklabels({'N3','N2','N1','REM','Wake'})
% xlabel('# epoch (30s / epoch)');
% ylabel('Stages');
% xlim([0 total_epoch])
% ylim([-3 3])
% title(['Hypnogram']);
% grid on
