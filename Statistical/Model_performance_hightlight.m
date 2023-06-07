close all;clc;clear all;
run('..\Function\load_function.m')
%% Run this to load file
path_file='..\Data_save\Result\Classification\Self-accquistion\Thesis';
[folder,name,ext]=Loadfile('.xlsx',path_file);
%% Get path
path_1=fullfile(folder{1},[name{1},ext{1}]);
path_2=fullfile(folder{2},[name{2},ext{2}]);
path_3=fullfile(folder{3},[name{3},ext{3}]);
% Meta data
folder_save_model_1=strsplit(name{1},'_');
folder_save_model_2=strsplit(name{2},'_');
folder_save_model_3=strsplit(name{3},'_');

window_name={folder_save_model_1{1},folder_save_model_2{1},folder_save_model_3{1}};
channel_name={'Fp1','Fp2','C3','C4','O1','O2'};
%%
model_performance_1=readtable(path_1);
model_performance_2=readtable(path_2);
model_performance_3=readtable(path_3);
%% Get model performance
%%
channels=unique(model_performance_1.Channel);
models=unique(model_performance_1.Model);
subjects=unique(model_performance_1.Subject_id);
objectives=channels;
Objectives='Channel';
%% Model performance
% Accuracy
accuracy_1=cellfun(@(x)model_performance_1.Accuracy(find(strcmp(model_performance_1.(Objectives),x))),objectives,'UniformOutput',false);
accuracy_2=cellfun(@(x)model_performance_2.Accuracy(find(strcmp(model_performance_2.(Objectives),x))),objectives,'UniformOutput',false);
accuracy_3=cellfun(@(x)model_performance_3.Accuracy(find(strcmp(model_performance_3.(Objectives),x))),objectives,'UniformOutput',false);

% Precision
precision_1=cellfun(@(x)model_performance_1.Precision(find(strcmp(model_performance_1.(Objectives),x))),objectives,'UniformOutput',false);
precision_2=cellfun(@(x)model_performance_2.Precision(find(strcmp(model_performance_2.(Objectives),x))),objectives,'UniformOutput',false);
precision_3=cellfun(@(x)model_performance_3.Precision(find(strcmp(model_performance_3.(Objectives),x))),objectives,'UniformOutput',false);

% Recall
recall_1=cellfun(@(x)model_performance_1.Recall(find(strcmp(model_performance_1.(Objectives),x))),objectives,'UniformOutput',false);
recall_2=cellfun(@(x)model_performance_2.Recall(find(strcmp(model_performance_2.(Objectives),x))),objectives,'UniformOutput',false);
recall_3=cellfun(@(x)model_performance_3.Recall(find(strcmp(model_performance_3.(Objectives),x))),objectives,'UniformOutput',false);

% F1 score
f1_1=cellfun(@(x)model_performance_1.F1(find(strcmp(model_performance_1.(Objectives),x))),objectives,'UniformOutput',false);
f1_2=cellfun(@(x)model_performance_2.F1(find(strcmp(model_performance_2.(Objectives),x))),objectives,'UniformOutput',false);
f1_3=cellfun(@(x)model_performance_3.F1(find(strcmp(model_performance_3.(Objectives),x))),objectives,'UniformOutput',false);

%% Summary 2 table
table_1=summary(model_performance_1);
table_2=summary(model_performance_2);
table_3=summary(model_performance_3);
%% Plotting model performance
performance_metrics_1=[accuracy_1,precision_1,recall_1,f1_1];
performance_metrics_2=[accuracy_2,precision_2,recall_2,f1_2];
performance_metrics_3=[accuracy_3,precision_3,recall_3,f1_3];
metrics_name={'Accuracy','Precision','Recall','F1'};
for i=1:size(performance_metrics_1,2)
%     performance_metrics_1=[accuracy_1{i},precision_1{i},recall_1{i},f1_1{i}];
    metric_1=horzcat({performance_metrics_1{:,i}});
    metric_1=cell2mat(metric_1);
    metric_2=horzcat({performance_metrics_2{:,i}});
    metric_2=cell2mat(metric_2);
    metric_3=horzcat({performance_metrics_3{:,i}});
    metric_3=cell2mat(metric_3);
    figure
    [model_mean{i},model_std{i}]=plot_performance_compare([metric_1,metric_2,metric_3],channel_name);
    title(metrics_name{i})
    legend(window_name)
    ylabel('Score');
    ylim([0 101]);
end
%% Statistical 
%% Prepare data
% metric_1=horzcat(f1_1{:});
% metric_2=horzcat(f1_2{:});
% metric_3=horzcat(f1_3{:});
metric_1=horzcat(accuracy_1{:});
metric_2=horzcat(accuracy_2{:});
metric_3=horzcat(accuracy_3{:});
%% Boxplot between group
name_x=[1:6];
figure
boxplot(metric_1,name_x);
h(1)=gca;
grid on
title([metrics_name{1},' of ',window_name{1},' Trial'])
ylabel('Score')
figure
boxplot(metric_2,name_x);
h(2)=gca;
grid on
title([metrics_name{1},' of ',window_name{2},' Trial'])
ylabel('Score')
figure
boxplot(metric_3,name_x);
h(3)=gca;
grid on
title([metrics_name{1},' of ',window_name{3},' Trial'])
ylabel('Score')
for i=1:length(h)
    h(i).YAxis.Limits=[-1 101];
    h(i).XTickLabel=channel_name;
end
%% Hypothesis
% Anova
% plot_anova(metric_1,metric_2,window_name);
% Kruskal-Wallis
for i=1:size(metric_1,2)
    metric_channel=[metric_1(:,i),metric_2(:,i),metric_3(:,i)];
    [p(i),~,stats(i)] = kruskalwallis(metric_channel,[],'off'); 
    figure
    multcompare(stats(i));
    title(['Channel ',num2str(i)])
end

%% Function plot performance
function plot_anova(metric_1,metric_2,window_name)
    [p,~,stats] =anova1(metric_1);
    multcompare(stats);
    title(['Anova of ',window_name{1}])
    [p,~,stats] =anova1(metric_2);
    multcompare(stats);
    title(['Anova of ',window_name{2}])
    %% Anova between 2 window
    for i=1:size(metric_1,2)
        accuracy=[metric_1(:,i),metric_2(:,i)];
        [p,~,stats] =anova1(accuracy,window_name,'off');
        figure
        multcompare(stats);
        title(["Channel ",num2str(i)])
        legend(window_name)
    end
end
function [bar_value,bar_err]=plot_performance_compare(model_performance,Group)
% models: a cell array of strings containing the names of the models
% accuracy: a vector of the accuracy scores for each model
% precision: a matrix of the precision scores for each model and class
% recall: a matrix of the recall scores for each model and class
    idx_nan=find(isnan(model_performance));
    if ~isempty(idx_nan)
        model_performance(idx_nan)=0;
    end
    bar_value=mean(model_performance);
    bar_value=reshape(bar_value,size(model_performance,2)/3,[]);
    % std
    bar_err =std(model_performance);
    bar_err=reshape(bar_err,size(model_performance,2)/3,[]);
%     num_x=[1:size(bar_value,1)];
%     name_x=sprintfc([Group,' %s'],num_x);
    % Plotting
    bar(bar_value);
    grid on
    % Errorbar
    hold on
    % Find the number of groups and the number of bars in each group
    [ngroups,nbars] = size(bar_value);
    % Calculate the width for each bar group
    groupwidth = min(0.8, nbars/(nbars + 1.5));
    % Set the position of each error bar in the centre of the main bar
    % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
    for i = 1:nbars
        % Calculate center of each bar
        x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
        errorbar(x, bar_value(:,i), bar_err(:,i), 'k', 'linestyle', 'none');
    end
    hold off
    xticklabels(Group)
    grid on
end
