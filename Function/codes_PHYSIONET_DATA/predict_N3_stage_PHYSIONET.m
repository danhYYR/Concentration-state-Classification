epoch_duration = input('How many seconds of an epoch? Value = ');%value of an epoch
total_epoch = fix(length(time_vector)/(fs*epoch_duration));
%flag_Delta_in_total_channels = (flag_Delta_in_channel_FpzCz | flag_Delta_in_channel_PzOz);
%flag_Delta_in_total_channels = logical((flag_Delta_in_channel_PzOz));
%flag_Delta_in_total_channels=labels;

% flag_N3_Stage=zeros(1,total_epoch);
% for i=1:total_epoch
%     if ((flag_Delta_in_total_channels(i)==1)&(flag_EMG_Average_high(i)==0))==1
%         flag_N3_Stage(i)=1;
%     else
%         flag_N3_Stage(i)=0;
%     end
% end

% flag_N3_Stage=zeros(1,total_epoch);
% for i=1:total_epoch
%     if ((flag_Delta_in_channel_PzOz(i)==1)&((flag_EMG_Power_high(i)==1)|(flag_EMG_Average_high(i)==1)))==1
%         flag_N3_Stage(i)=1;
%     else
%         flag_N3_Stage(i)=0;
%     end
% end

flag_N3_Stage=zeros(1,total_epoch);
for i=1:total_epoch
    if ((flag_new_Delta_in_channel_PzOz(i)==1)&((flag_EMG_Average_high(i)==1)))|((flag_new_Delta_in_channel_PzOz(i)==1)&((flag_EMG_Power_high(i)==1)))==1
        flag_N3_Stage(i)=1;
    else
        flag_N3_Stage(i)=0;
    end
end

% flag_N3_Stage=zeros(1,total_epoch);
% for i=1:total_epoch
%     if flag_Delta_in_total_channels(i)==1
%         flag_N3_Stage(i)=1;
%     else
%         flag_N3_Stage(i)=0;
%     end
% end

FINAL_flag_N3_Stage=flag_N3_Stage;

for i=2:1:length(flag_N3_Stage)-4
    if flag_N3_Stage(i)==0 % OFF state
        if flag_N3_Stage(i-1)==1 & flag_N3_Stage(i+1)==1
            FINAL_flag_N3_Stage(i)=1;
        else
            FINAL_flag_N3_Stage(i)=FINAL_flag_N3_Stage(i);
        end
    elseif flag_N3_Stage(i)==1 % ON state
        if flag_N3_Stage(i-1)==0 & flag_N3_Stage(i+1)==0
            FINAL_flag_N3_Stage(i)=0;
        else
            FINAL_flag_N3_Stage(i)=FINAL_flag_N3_Stage(i);
        end
    end
end


%Smoothing Stages many times
number_of_repeation_smoothing = input('How many steps apply for smoothing signal = ');%the value number of smoothing step
for k=1:number_of_repeation_smoothing
    
FINAL_flag_N3_Stage=flag_N3_Stage;

for i=4:1:length(flag_N3_Stage)-4
    if flag_N3_Stage(i)==0 % OFF state
        if flag_N3_Stage(i-1)==1 & flag_N3_Stage(i+1)==1
            FINAL_flag_N3_Stage(i)=1;
        elseif flag_N3_Stage(i-1)==0 & flag_N3_Stage(i+1)==0
            if flag_N3_Stage(i-2)==1 & flag_N3_Stage(i+2)==1
                FINAL_flag_N3_Stage(i)=1;
                FINAL_flag_N3_Stage(i-1)=1;
                FINAL_flag_N3_Stage(i+1)=1;
            else
                FINAL_flag_N3_Stage(i)=0;
            end        
        else
            FINAL_flag_N3_Stage(i)=FINAL_flag_N3_Stage(i);
        end
    elseif flag_N3_Stage(i)==1 % ON state
        if flag_N3_Stage(i-1)==0 & flag_N3_Stage(i+1)==0
            FINAL_flag_N3_Stage(i)=0;
        elseif flag_N3_Stage(i-1)==1 & flag_N3_Stage(i+1)==1
            if flag_N3_Stage(i-2)==0 & flag_N3_Stage(i+2)==0
                FINAL_flag_N3_Stage(i)=0;
                FINAL_flag_N3_Stage(i-1)=0;
                FINAL_flag_N3_Stage(i+1)=0;
            else
                FINAL_flag_N3_Stage(i)=1;
            end        
            FINAL_flag_N3_Stage(i)=FINAL_flag_N3_Stage(i);
        end
    end
end
    flag_N3_Stage=FINAL_flag_N3_Stage;
end

figure
subplot(2,1,1)
t=1:total_epoch;
plot(t,FINAL_flag_N3_Stage);
title('Predict N3 Stage');
ylim([-1 2])
set(gca,'YTick',-1:1:2)
set(gca,'YTickLabel',{'','None','Predict N3',''})
ylabel('Stages')
%xlim([800 1800]);


stages=[];
for i=1:total_epoch
    temp=mean(STAGE(epoch_duration*(i-1)+1:epoch_duration*i));
    if temp == 1 % Stage N1
       temp=0;
    elseif temp==2 % Stage N2
       temp=0;
    elseif temp==3 % Stage N3
       temp=1;
    elseif temp==4 % Stage REM
       temp=0; 
    else % Wake Stage
       temp=0;
    end
    stages=[stages;temp];
end
subplot(2,1,2)
plot(t,stages);
title('Actual N3 Stage');
ylim([-1 2])
set(gca,'YTick',-1:1:2)
set(gca,'YTickLabel',{'','Other','N3',''})
xlabel('Number of epoch (30s / epoch)')
ylabel('Stages')
%xlim([800 1800]);

figure;
plot(t,FINAL_flag_N3_Stage,'b','Linewidth',3);
title('Predict N3 Stage & Actual N3 Stage');
ylim([-1 2])
xlim([800 1800]);
ylabel('Stages')
set(gca,'YTick',-1:1:2)
set(gca,'YTickLabel',{'','None','N3',''})
hold on;
plot(t,stages,'r','Linewidth',3);
hold off

% This script calculate some statistical parameters
%g1=flag_Delta_in_total_channels;
g1=logical(flag_N3_Stage);
g2=logical(stages);
%g1=g1(800:1800);
%g2=g2(800:1800);
confusion_matrix = confusionmat(g1,g2);
figure;
cm = confusionchart(g2,g1, ...
    'ColumnSummary','column-normalized', ...
    'RowSummary','row-normalized');
[row,col] = size(confusion_matrix);
all_True=0;
% precision or positive predictive value (PPV) _ User's Accuracy
cal_PPV=[];
% false discovery rate (FDR)
cal_FDR=[];
% sensitivity, recall, hit rate, or true positive rate (TPR) _ or Producer’s Accuracy
cal_TPR=[];
% miss rate or false negative rate (FNR)
cal_FNR=[];
% specificity, selectivity or true negative rate (TNR)
cal_TNR=[];
% fall-out or false positive rate (FPR)
cal_FPR=[];
% F1 score
cal_F1_score=[];
% F1 macro score
cal_F1_macro_score=[];
for i=1:row
    all_True=all_True+confusion_matrix(i,i);
    cal_PPV(i)=confusion_matrix(i,i)/sum(confusion_matrix(i,:));
    cal_FDR(i)=1-cal_PPV(i);
    cal_TPR(i)=confusion_matrix(i,i)/sum(confusion_matrix(:,i));
    cal_FNR(i)=1-cal_TPR(i);
    cal_F1_score(i)=(2*cal_PPV(i)*cal_TPR(i))/(cal_PPV(i)+cal_TPR(i));
    cal_F1_macro_score(i)=(cal_F1_score(i)+cal_PPV(i)+cal_TPR(i))/3;
end
for i=1:row
    cal_TNR(i)=(all_True-confusion_matrix(i,i))/((all_True-confusion_matrix(i,i))+(sum(confusion_matrix(i,:))-confusion_matrix(i,i)));
    cal_FPR(i)=1-cal_TNR(i);
end

cal_TPR
cal_TNR
cal_PPV
cal_FNR
cal_FPR
cal_FDR
Accuracy = all_True/sum(sum(confusion_matrix))
cal_F1_score
cal_F1_macro_score
%ROC curve
figure;
plot(cal_FPR,cal_TPR,'-o',[0 1],[0 1],'r')
title('ROC curve')
xlabel('False Positive Rate')
ylabel('True Positive Rate')
axis equal
axis([0 1 0 1])
grid on
   