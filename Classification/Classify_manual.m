close all;clc;clear all;
run('..\Function\load_function.m')
%% Run this to load file
path_file='..\Data_save\Feature_extraction\Self_accquistion';
[folder,name,ext]=Loadfile('.mat',path_file);
%% Get path
path_data=fullfile(folder,[name,ext]);
%% LoadEEG Feature
p_data=load(path_data);
p_data=p_data.p_global;
p_data=struct2cell(p_data)';
i_channel=size(p_data,2)-1;
feature=[1:12];
subject_id='Global';
subject_train=[3];
%% Run build model
for j=1:i_channel
  %% Prepare feature
    data=vertcat(p_data{subject_train,j});
    label={'Rest','Concentration'};
    value_label=[-1,0];
    p_gr=vertcat(p_data{subject_train,end});
    data(:,13)=p_gr;
    % Get label
    p_label=categorical(data(:,end),value_label,label);
    % Create train and test set
    i_remove=find(data(:,13)==1);
    data(i_remove,:)=[];
    p_gr(i_remove,:)=[];
    p_label(i_remove,:)=[];

    %% Create validation
    n=length(data);
    k=10;
    c = cvpartition(p_gr,'LeaveOut');   % Create k-fold validatetion
%     c = cvpartition(p_gr,'kfold',k);   % Create k-fold validatetion

    predict_model1=nan*ones(ceil(length(data)/k),c.NumTestSets);
    predict_model2=nan*ones(ceil(length(data)/k),c.NumTestSets);
    %% Train and test model
    for k=1:c.NumTestSets
        train_i=training(c,k);
        test_i=test(c,k);
        y_train = data(train_i,13);        % y train
        x_train = data(train_i,1:end-1);    % get x_train
        y_test{k} = data(test_i,13);          % y test
        x_test = data(test_i,1:end-1);      % get x_test;
        %% Classification with SVM
        t_SVM = templateSVM('Standardize',true,'KernelFunction','RBF');
        Md1 = fitcecoc(x_train(:,feature),y_train,'Learners',t_SVM); 
        % Test data
        predict_model1(1:length(y_test{k}),k)=predict(Md1,x_test(:,feature));
        acc_model1(k)= sum(predict_model1(1:length(y_test{k}),k)== y_test{k})/length(y_test{k})*100;
        %% Classification with RF
        t_tree=templateTree('NumVariablesToSample','all');
        Md2=fitensemble(x_train(:,feature),y_train,'Bag',100,'Tree','Type','classification','Learners',t_tree);
        predict_model2(1:length(y_test{k}),k)=predict(Md2,x_test(:,feature));
        acc_model2(k)=sum(predict_model2(1:length(y_test{k}),k)==y_test{k})/length(y_test{k})*100;
        Model{1,k}=Md1;
        Model{2,k}=Md2;
    end
    %% Feature Importance
    feature_rank=Feature_selection_control(horzcat(Model(2,:)),'Random Forest');
    Table_Permu=feature_rank{1};
    Table_Gini=feature_rank{2};
    %% Accuracy following k fold
    acc_avr_model1=mean(acc_model1);
    acc_avr_model2=mean(acc_model2);
    i_fold_best_1=find(acc_model1==max(acc_model1));
    i_fold_best_2=find(acc_model2==max(acc_model2));
%% Confusion matrix chart
    % Confusion matrix for each Fold
    for k=1:c.NumTestSets
        test_i=test(c,k);
        y_actual=p_label(test_i);
        predict_label1=categorical(predict_model1(:,k),value_label,label);
        predict_label2=categorical(predict_model2(:,k),value_label,label);
        predict_label1(find(isundefined(predict_label1)))=[];
        predict_label2(find(isundefined(predict_label2)))=[];
        cm1{k}=confusionmat(y_actual,predict_label1);
        cm2{k}=confusionmat(y_actual,predict_label2);
    end
        % Cfs matrix with best fold
        y_actual=categorical(cell2mat(y_test'),value_label,label);
        predict_model_best_1=reshape(predict_model1,[],1);
        predict_model_best_2=reshape(predict_model2,[],1);
        predict_label1=categorical(predict_model_best_1,value_label,label);
        predict_label2=categorical(predict_model_best_2,value_label,label);
        predict_label1(find(isundefined(predict_label1)))=[];
        predict_label2(find(isundefined(predict_label2)))=[];
        figure('Name',['Channel ',num2str(j)])
       
        subplot(2,1,1)
        cm1{k+1}=confusionmat(y_actual,predict_label1);
        heatmap(label,label,cm1{end});
        title('Confusion matrix with SVM Model')
        subplot(2,1,2)
        cm2{k+1}=confusionmat(y_actual,predict_label2);
        heatmap(label,label,cm2{end});
        title('Confusion matrix with RF model')
end