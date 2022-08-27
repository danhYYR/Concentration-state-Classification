%This script detect REM stage from PHYSIONET database
epoch_duration = input('How many seconds of an epoch? Value = ');%value of an epoch
total_epoch = fix(length(time_vector)/(fs*epoch_duration));
figure
stages=[];

for i=1:total_epoch
    temp=mean(STAGE(epoch_duration*(i-1)+1:epoch_duration*i));
    if temp == 1 % Stage N1
       temp=0;
    elseif temp==2 % Stage N2
       temp=0;
    elseif temp==3 % Stage N3
       temp=0;
    elseif temp==4 % Stage REM
       temp=1; 
    else % Wake Stage
       temp=0;
    end
    stages=[stages;temp];
end



subplot(5,1,1)
plot(t,flag_EMG_Power_high);
% title('Epoch has high EMG signal');
title('Power high EMG signal');
ylim([-1 2])
set(gca,'YTick',-1:1:2)
set(gca,'YTickLabel',{'','low EMG','high EMG',''})
ylabel('flag EMG high Power')

subplot(5,1,2)
plot(t,flag_EMG_Average_high);
% title('Epoch has high EMG signal');
title('Average high EMG signal');
ylim([-1 2])
set(gca,'YTick',-1:1:2)
set(gca,'YTickLabel',{'','low EMG','high EMG',''})
ylabel('flag EMG high Average')

CREM_threshold=func_threshold(all_total_REM_epoch)
flag_predict_REM=[];
for i=1:total_epoch
    if ((all_total_REM_epoch(i)<=CREM_threshold) & (flag_EMG_Power_high(i)==1))==1 % must have 2 conditions
        temp = 1;
    else
        temp = 0;
    end
    flag_predict_REM=[flag_predict_REM temp];
end

% temp=0;
% CREM_threshold=func_threshold(all_total_REM_epoch);
% flag_CREM=zeros(total_epoch,1);
% for i=1:total_epoch
%         if all_total_REM_epoch(i) >= CREM_threshold + CREM_threshold/4
%             flag_CREM(i)=1; %high CREM
%         elseif all_total_REM_epoch(i) <= CREM_threshold - CREM_threshold/4
%             flag_CREM(i)=-1; %low CREM
%         else
%             flag_CREM(i)=0; % medium CREM
%         end
% end
% 
t=1:total_epoch;
subplot(5,1,3)
plot(t,all_total_REM_epoch);
title('Epoch with CREM value');
%ylim([-2 2])
ylabel('Value of CREM')

% flag_predict_REM=[];
% for i=1:total_epoch
%     if ((flag_EMG_Average_high(i)==0) & (flag_EMG_Power_high(i)==-1))==1 % must have 2 conditions
%         if flag_CREM(i)==-1
%             temp=1;
%         else
%             if ((flag_CREM(i)==0) & (flag_EMG_Average_high(i)==0))==1 % must have 2 conditions
%                 temp=1;
%             end
%             temp=0;
%         end
%     elseif (((flag_CREM(i)==0)|(flag_CREM(i)==-1)) & (flag_EMG_Power_high(i)==0) )==1 % must have 2 conditions
%         temp=1;
%     elseif ((flag_CREM(i)==0) & (flag_EMG_Power_high(i)==-1) &(flag_EMG_Average_high(i)==0) )==1 % must have 3 conditions
%        temp=1;    
%     else
%        temp=0;
%     end
%     flag_predict_REM=[flag_predict_REM temp];
% end

%Smoothing Stages
FINAL_flag_predict_REM=flag_predict_REM;

for i=2:1:length(flag_predict_REM)-4
    if flag_predict_REM(i)==0 % OFF state
        if flag_predict_REM(i-1)==1 & flag_predict_REM(i+1)==1
            FINAL_flag_predict_REM(i)=1;
        else
            FINAL_flag_predict_REM(i)=FINAL_flag_predict_REM(i);
        end
    elseif flag_predict_REM(i)==1 % ON state
        if flag_predict_REM(i-1)==0 & flag_predict_REM(i+1)==0
            FINAL_flag_predict_REM(i)=0;
        else
            FINAL_flag_predict_REM(i)=FINAL_flag_predict_REM(i);
        end
    end
end

%Smoothing Stages many times
number_of_repeation_smoothing = input('How many steps apply for smoothing signal = ');%the value number of smoothing step
for k=1:number_of_repeation_smoothing
    
FINAL_flag_predict_REM=flag_predict_REM;

for i=4:1:length(flag_predict_REM)-4
    if flag_predict_REM(i)==0 % OFF state
        if flag_predict_REM(i-1)==1 & flag_predict_REM(i+1)==1
            FINAL_flag_predict_REM(i)=1;
        elseif flag_predict_REM(i-1)==0 & flag_predict_REM(i+1)==0
            if flag_predict_REM(i-2)==1 & flag_predict_REM(i+2)==1
                FINAL_flag_predict_REM(i)=1;
                FINAL_flag_predict_REM(i-1)=1;
                FINAL_flag_predict_REM(i+1)=1;
            else
                FINAL_flag_predict_REM(i)=0;
            end        
        elseif flag_predict_REM(i-2)==0 | flag_predict_REM(i+2)==0
            FINAL_flag_predict_REM(i)=0;
            FINAL_flag_predict_REM(i-1)=0;
            FINAL_flag_predict_REM(i+1)=0;
        else
            FINAL_flag_predict_REM(i)=FINAL_flag_predict_REM(i);
        end
    elseif flag_predict_REM(i)==1 % ON state
        if flag_predict_REM(i-1)==0 & flag_predict_REM(i+1)==0
           FINAL_flag_predict_REM(i)=0;
        elseif flag_predict_REM(i-1)==1 & flag_predict_REM(i+1)==1
            if flag_predict_REM(i-2)==0 & flag_predict_REM(i+2)==0
                FINAL_flag_predict_REM(i)=0;
                FINAL_flag_predict_REM(i-1)=0;
                FINAL_flag_predict_REM(i+1)=0;
            else
                FINAL_flag_predict_REM(i)=1;
            end        
        elseif flag_predict_REM(i-2)==1 | flag_predict_REM(i+2)==1
                FINAL_flag_predict_REM(i)=1;
                FINAL_flag_predict_REM(i-1)=1;
                FINAL_flag_predict_REM(i+1)=1;
        else
            FINAL_flag_predict_REM(i)=FINAL_flag_predict_REM(i);
        end
    end
end
    flag_N3_Stage=FINAL_flag_N3_Stage;
end

subplot(5,1,4)
plot(t,FINAL_flag_predict_REM);
title('Analysis of REM Stage');
ylim([-1 2])
set(gca,'YTick',-1:1:2)
set(gca,'YTickLabel',{'','Other','REM',''})
ylabel('Stages')

subplot(5,1,5)
plot(t,stages);
ylim([-1 2])
set(gca,'YTick',-1:1:2)
set(gca,'YTickLabel',{'','Other','REM',''})
xlabel('Number of epoch (30s / epoch)')
ylabel('Stages')
%debug_statistic

% This script calculate some statistical parameters
%g1=flag_Delta_in_total_channels;
g1=logical(FINAL_flag_predict_REM);
g2=logical(stages);
g1=g1(800:1800);
g2=g2(800:1800);
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