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
num_try=5;
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
    % Ratio Alpha/Gamma
    data(:,12)=data(:,3)./data(:,5);
    p_gr=p_data.('label');
    data(:,13)=p_gr;
    % Get label
    p_label=categorical(data(:,end),value_label,label);
    %    Create train and test set
    i_remove=find(data(:,13)==2);
    data(i_remove,:)=[];
    p_gr(i_remove,:)=[];
    p_label(i_remove,:)=[];
    %% Classification with RF
    %% Create validation
    n=length(data);
    k=10;
    c = cvpartition(p_gr,'k',k);   % Create k-fold validatetion
    predict_model1=nan*ones(ceil(length(data)/k),c.NumTestSets);
    predict_model2=nan*ones(ceil(length(data)/k),c.NumTestSets);

%% Train and test model
for i=1:num_try
    for j=1:c.NumTestSets
        train_i=training(c,j);
        test_i=test(c,j);
        y_train = p_gr(train_i);        % y train
        x_train = data(train_i,feature);    % get x_train
        y_test = p_gr(test_i);          % y test
        x_test = data(test_i,feature);      % get x_test
        y_actual(:,j)=y_test;
        num_tree=100;
        t=templateTree('NumVariablesToSample',sqrt(length(feature)));
        Md{j,i}=fitensemble(x_train(:,feature),y_train,'Bag',num_tree,'Tree','Type','classification','Learners',t);
        % Predict
        predict_label{i}(:,j)=predict(Md{j,i},x_test);
        acc_model(j,i)=sum(predict_label{i}(1:length(y_test),j)==y_test)/length(y_test)*100;
    end
end
%% Find the best model
for i=1:num_try
    Md_best{:,i}=Md{find(acc_model(:,i)==max(acc_model(:,i)))};
    oob_loss(:,i)=oobLoss(Md_best{:,i},'mode','individual');;
    permutation(i,:)=oobPermutedPredictorImportance(Md_best{:,i});
    feature_importance(i,:)=predictorImportance(Md_best{:,i});
end
%% Check with oob error
% figure
% plot(oob_loss)
% xlabel('Number of Grown Trees')
% ylabel('Out-of-Bag Classification Error')
%% Feature selection
%% Feature Permutation
figure
boxplot(permutation)
xlabel('Feature Index')
ylabel('Out-of-Bag Feature Importance')
title('Permuted Feature Selection')
%% Feature importance
figure
boxplot(feature_importance)
xlabel('Feature Index')
ylabel('Importance value')
title('Feature importance of RF')

%%
% %% Save Figure
% if ~exist('folder_save')
%     folder_save=uigetdir;
% end
% %%
% path_save=[folder_save,'\',name];
% name_save=[channel_name];
% saveCompactModel(Md1,[folder_save,'\',name_save,channel_name,'_TreeBagging']);
% saveCompactModel(Md,[folder_save,'\',name_save,channel_name,'_RF']);