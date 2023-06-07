%% Add path
close all;clc;clear all;
addpath('..\Function');
addpath('..\Function\Wavelet');
addpath('..\Function\codes_PHYSIONET_DATA');
addpath('..\Function\FourierTransform');
%% Classification
% feature: Delta-Theta-Alpha-Beta-Gamma
%% Load file
[folder,name,ext]=Loadfile();
path=[folder,'\',name];
%% Run this to load file
disp(name);
sample_file=1;
load(path);
channel_i=2;
%%
i=1
channel_name=['channel',num2str(i)];
data=vertcat(p_data.(channel_name));
label={'Rest','Concentration'};
value_label=[-1,1];
n=length(data);
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
p_gr=[ones(floor(length(data)/2),1);-1*ones(floor(length(data)/2),1)];
p_label=categorical(data(:,end),value_label,label);
p_feature={'Delta',...
                ;'Theta',...
                ;'Alpha',...
                ;'Beta',...
                ;'Gamma (30-70 Hz)',...
                ;'Beta/Theta',...
                ;'Alpha/Beta',...
                ;'Theta/Alpha',...
                ;'Alpha+Beta+Gamma',...
                ;'Theta/Beta',...
                ;'Beta/(Theta+Alpha)',...
                ;'Alpha/Gamma'};
%% Classification with RF
feature=[1:12];
feature_get=p_feature{feature};
c = cvpartition(n,'Holdout',0.3);   % Create k-fold validatetion
%% Train and test model
for j=1:c.NumTestSets
    train_i=training(c,j);
    test_i=test(c,j);
    y_train = p_gr(train_i);        % y train
    x_train = data(train_i,feature);    % get x_train
    y_test = p_gr(test_i);          % y test
    x_test = data(test_i,feature);      % get x_test
    y_actual(:,j)=y_test;
    num_tree=100;
    t = templateTree('NumVariablesToSample','all','Reproducible',true);
    Md1 = TreeBagger(num_tree,data(:,feature),p_gr,'OOBPredictorImportance','On');      
    Md2=fitensemble(data(:,feature),p_gr,'Bag',num_tree,'Tree','Type','classification','Learners',t);
    % Predict
    predict_label1(:,j)=predict(Md1,x_test);
    predict_label2(:,j)=predict(Md2,x_test);
    Md=fitcsvm(x_train(:,feature),y_train,'Standardize',true,'KernelFunction','RBF');
end
%% Check feature important
fs_permutation=Md1.OOBPermutedPredictorDeltaError;
fs_permutation_sort=sort(fs_permutation);
fs_i_1=find(fs_permutation==fs_permutation_sort(end));
fs_i_2=find(fs_permutation==fs_permutation_sort(end-1));
feature_best_1=[fs_i_1 fs_i_2];
%% Check Fearture importance
fs_feature_importance=predictorImportance(Md2);
fs_feature_importance_sort=sort(fs_feature_importance);
fs_i_1=find(fs_feature_importance==fs_feature_importance_sort(end));
fs_i_2=find(fs_feature_importance==fs_feature_importance_sort(end-1));
feature_best_2=[fs_i_1 fs_i_2];
%% Feature selection with Tau (manual)
[tau p]=corr(data,p_gr,'Type','Kendall');
fs_tau=find(abs(tau)>=0.2);
% Tau cross correlation
[tau_cross p]=corr(data(:,fs_tau),'Type','Kendall');
fs_tau_cross=find(abs(tau_cross)<=0.5);
feature_best_3=[3 4];
%% Train against
for j=1:c.NumTestSets
    train_i=training(c,j);
    test_i=test(c,j);
    y_train = p_gr(train_i);        % y train
    x_train = data(train_i,feature);    % get x_train
    y_test = p_gr(test_i);          % y test
    x_test = data(test_i,feature);      % get x_test
    y_actual(:,j)=y_test;
    Md_fs_1=fitcsvm(x_train(:,feature_best_1),y_train,'Standardize',true,'KernelFunction','RBF');
    Md_fs_2=fitcsvm(x_train(:,feature_best_2),y_train,'Standardize',true,'KernelFunction','RBF');
    Md_fs_3=fitcsvm(x_train(:,feature_best_3),y_train,'Standardize',true,'KernelFunction','RBF');
end

%% Predict
% Predict based on feature
predict_Md__label(:,j)=predict(Md,x_test);
% Predict after use feature selection
predict_Md_fs_label1(:,j)=predict(Md_fs_1,x_test(:,feature_best_1));
predict_Md_fs_label2(:,j)=predict(Md_fs_2,x_test(:,feature_best_2));
predict_Md_fs_label3(:,j)=predict(Md_fs_3,x_test(:,feature_best_3));
%% Cfs matrix
figure
subplot(2,1,1)
confusionchart(y_actual,predict_Md__label...
    ,'ColumnSummary','column-normalized');
title('Confusion matrix with all feature')
subplot(2,1,2)
confusionchart(y_actual,predict_Md_fs_label1,...
    'ColumnSummary','column-normalized');
title('Confusion matrix with permutation')

figure
subplot(2,1,1)
confusionchart(y_actual,predict_Md__label,...
    'ColumnSummary','column-normalized');
title('Confusion matrix with all feature')

subplot(2,1,2)
confusionchart(y_actual,predict_Md_fs_label2,...
    'ColumnSummary','column-normalized');
title('Confusion matrix with Feature importance')

figure
subplot(2,1,1)
confusionchart(y_actual,predict_Md__label,...
    'ColumnSummary','column-normalized');
title('Confusion matrix with all feature')

subplot(2,1,2)
confusionchart(y_actual,predict_Md_fs_label3,...
    'ColumnSummary','column-normalized');
title('Confusion matrix with Tau')
