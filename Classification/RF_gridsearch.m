%% Prepare
close all;clc;clear all;
run('..\Function\load_function.m')
%% Classification
% feature: Delta-Theta-Alpha-Beta-Gamma
%% Load file
[folder,name,ext]=Loadfile('.mat','..\Data_save\Feature_extraction\Reference\EEG_ET_simoulous');
path=[folder,'\',name];
%% Run this to load file
disp(name);
sample_file=1;
load(path);
feature=[1:12];
%%
i=1
    channel_name=['channel',num2str(i)];
     data=p_data.(channel_name);
    label={'Rest','Concentration','Concentration high'};
    value_label=[-1,0,1];
    % Beta/Theta
    data(:,6)=data(:,4)./data(:,2);
    % Alpha/Beta
    data(:,7)=data(:,3)./data(:,4);
    % Theta/Alpha
    data(:,8)=data(:,2)./data(:,3);
    % Sum Alpha Beta Gamma
    data(:,9)=sum(data(:,3:5),2);
    % Ratio Theta/Beta
    data(:,10)=data(:,2)./data(:,4);
    % Ratio Beta/(Alpha+Theta)
    data(:,11)=data(:,4)./sum(data(:,2:3),2);
    % RatioAlpha/Gamma
    data(:,12)=data(:,3)./data(:,5);
    p_gr=p_data.('label');
    % Get label
    p_label=categorical(data(:,end),value_label,label);
    %    Create train and test set
    i_remove=find(data(:,13)==1);
    data(i_remove,:)=[];
    p_gr(i_remove,:)=[];
    p_label(i_remove,:)=[];
    %% Classification with RF
    %% Create validation
    n=length(data);
    k=5;
    c = cvpartition(p_gr,'k',k);   % Create k-fold validatetion
    %% Create grid search parameter for RF
    %{'Method','NumLearningCycles','LearnRate','MinLeafSize','MaxNumSplits'}
%% Using hyperparameters function
grid_hyperparameter = hyperparameters('fitcensemble',data,p_gr,'Tree');
grid_hyperparameter(1).('Range')={'Bag','AdaBoostM1'};
grid_hyperparameter_remove=[1,3,6,7];
% Keep NumTrees,MinLeafSize,MaxNumSplits
grid_hyperparameter(grid_hyperparameter_remove)=[];
% Choose optimazation option
opts = struct('Optimizer','gridsearch','MaxObjectiveEvaluations',30, ...
                'CVPartition',c,...
                'ShowPlots', false);

%% Train random forest model with optimized hyperparameters using k-fold cross-validation
model = fitcensemble(data(:,1:end-1), p_gr, 'Method', 'Bag',...
     'OptimizeHyperparameters',grid_hyperparameter,...
     'HyperparameterOptimizationOptions', opts);
%% Get best modelparameters
model_rank=model.HyperparameterOptimizationResults(:,{'Rank'});
grid_best=find(cell2mat(table2cell(model_rank))==1);
hyperparameters_best=model.HyperparameterOptimizationResults(grid_best,1:2);
para_field_1=hyperparameters_best.Properties.VariableNames{1};
para_1=hyperparameters_best.(para_field_1);
para_field_2=hyperparameters_best.Properties.VariableNames{2};
para_2=hyperparameters_best.(para_field_2);
%% Train and test model
Md={};
predict_label=[];
for j=1:c.NumTestSets
    train_i=training(c,j);
    test_i=test(c,j);
    y_train = data(train_i,13);        % y train
    x_train = data(train_i,1:end-1);    % get x_train
    y_test{j} = data(test_i,13);          % y test
    x_test = data(test_i,1:end-1);      % get x_test;
    %% Classification with RF
    t=templateTree(para_field_2,para_2);       
    Md{j}=fitensemble(x_train(:,feature),y_train,'Bag',para_1,'Tree','Type','classification');
    predict_label(1:length(y_test{j}),j)=predict(Md{j},x_test(:,feature));
end
%% Check Perfomance
%% Confusion matrix chart
% Confusion matrix for each Fold
for j=1:c.NumTestSets
    test_i=test(c,j);
    y_actual=p_gr(test_i);
    cm{j}=confusionmat(y_actual,predict_label(:,j));
end
    %% Performance model
    %% Caculate Accuracy,Recall,F1 score
for j=1:c.NumTestSets
        accuracy(j)= trace(cm{j})/sum(cm{j},'all')*100;
        precision(j)= cm{j}(4)/(cm{j}(3)+cm{j}(4))*100;
        recall(j)=cm{j}(4)/(cm{j}(2)+cm{j}(4))*100;
        F1(j)=2*precision(j)* recall(j)/( precision(j)+recall(j));
end
model_performace=[accuracy',precision',recall',F1'];

%% Boxplot performance of model
% Label
box_label={'Accuracy','Precision','Recall','F1 score'};
figure
boxplot(model_performace,'Labels',box_label);
title('5 Fold Performance for model RF')