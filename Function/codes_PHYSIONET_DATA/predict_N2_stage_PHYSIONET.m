epoch_duration = input('How many seconds of an epoch? Value = ');%value of an epoch
total_epoch = fix(length(time_vector)/(fs*epoch_duration));
stages=[];
for i=1:total_epoch
    temp=mean(STAGE(epoch_duration*(i-1)+1:epoch_duration*i));
    if temp == 1 % Stage N1
       temp=0;
    elseif temp==2 % Stage N2
       temp=1;
    elseif temp==3 % Stage N3
       temp=0;
    elseif temp==4 % Stage REM
       temp=0; 
    else % Wake Stage
       temp=0;
    end
    stages=[stages;temp];
end

flag_Microwaves_in_total_channels = (flag_Microwaves_in_channel_FpzCz | flag_Microwaves_in_channel_PzOz);
figure
subplot(2,1,1)
t=1:length(stages);
plot(t,flag_Microwaves_in_total_channels);
title('Analysis result of N2 Stage');
ylim([-1 2])
set(gca,'YTick',-1:1:2)
set(gca,'YTickLabel',{'','Other','N2',''})
xlabel('Number of epoch (30s / epoch)')
ylabel('Stages')

subplot(2,1,2)
plot(t,stages);
ylim([-1 2])
set(gca,'YTick',-1:1:2)
set(gca,'YTickLabel',{'','Other','N2',''})
xlabel('Number of epoch (30s / epoch)')
ylabel('Stages')

% This script calculate some statistical parameters
g1=flag_Microwaves_in_total_channels;
g2=logical(stages);
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
