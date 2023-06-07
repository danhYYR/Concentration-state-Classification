close all;clc;clear all;
run('..\Function\load_function.m')
%% Run this to load file
path_file='..\Data_save\Feature_extraction\Self_accquistion';
path_folder=uigetdir(path_file,'Choose folder to autoload');
% Getpath save
if ~exist('folder_save')
    folder_save=uigetdir('..\Data_save\Result\Classification\Self-accquistion\Thesis','Choose where do you want to save');
end
% Get a list of all subfolders in the root folder
subfolders = dir(path_folder);
subfolders = subfolders([subfolders(:).isdir] & ~ismember({subfolders(:).name}, {'.', '..'}));
%% Auto generate folder
for i=1:length(subfolders)
    % Extract the subject name from the file name
    name_subject=subfolders(i).name;
    mkdir(fullfile(folder_save,name_subject));
end
%% Prepare table to save data
Table_model_1=table();
Table_model_2=table();
%% Loop over each subfolder and process its files
for i = 1:length(subfolders)
% i_error=8;
% for i = i_error:length(subfolders)

        file = subfolders(i);
        fileName = 'PowerFeature.mat';
        path_data=fullfile(file.folder,file.name, fileName);
        %% LoadEEG
        p_data=load(path_data);
        p_data=p_data.p_power;
        i_channel=length(fieldnames(p_data))-1;
        feature=[1:12];

%% Run build model
for j=1:i_channel
    %% Prepare feature
    channel_name=['channel',num2str(j)];
    data=p_data.(channel_name);
    label={'Rest','Concentration'};
    value_label=[-1,0];
    p_gr=p_data.('label');
    data(:,end+1)=p_gr;
    % Get label
    p_label=categorical(data(:,end),value_label,label);
    % Create train and test set
    i_remove=find(data(:,end)==1);
    data(i_remove,:)=[];
    p_gr(i_remove,:)=[];
    p_label(i_remove,:)=[];

    %% Create validation
    n=length(data);
    k=10;
    c = cvpartition(p_gr,'LeaveOut');   
%     c = cvpartition(p_gr,'KFold',k);   
%     c = cvpartition(p_gr,'Holdout',0.3);   

%     predict_model1=nan*ones(ceil(length(data)/k),c.NumTestSets);
%     predict_model2=nan*ones(ceil(length(data)/k),c.NumTestSets);
    %% Train and test model
    for k=1:c.NumTestSets
        train_i=training(c,k);
        test_i=test(c,k);
        y_train = data(train_i,end);        % y train
        x_train = data(train_i,1:end-1);    % get x_train
        y_test{k}  = data(test_i,end);          % y test
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
        %% Store Model
        Model{1,k}=Md1;
        Model{2,k}=Md2;
    end
    %% Prepare save name
    subject_id=subfolders(i).name;
    disp(subject_id);
    disp('Remain');
    disp(length(subfolders)-i);
    path_save=fullfile(folder_save,subject_id);
    folder_save_channel=fullfile(path_save,channel_name);
    % Create folder to save
    mkdir (folder_save_channel)
    path_save_figure=[folder_save_channel,'\',channel_name];
    name_save=[channel_name];
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
        figure('Name','Best Fold in entire dataset')
       
        subplot(2,1,1)
        cm1{k+1}=confusionmat(y_actual,predict_label1);
        heatmap(label,label,cm1{end},'FontSize',20);
        title('Confusion matrix with SVM Model')
        subplot(2,1,2)
        cm2{k+1}=confusionmat(y_actual,predict_label2);
        heatmap(label,label,cm2{end},'FontSize',20);
        title('Confusion matrix with RF model')
        %% Save cfs matrix
        set(gcf,'WindowState','maximized');
        saveas(gcf,[path_save_figure,'_Allsample_cfsmatrix.bmp']);
        close all
    %% Performance mode
    % Feature Name
    feature_header={'Delta',...
                    ;'Theta',...
                    ;'Alpha',...
                    ;'SMR'...
                    ;'Beta_Mid',...
                    ;'Beta_High'...
                    ;'Gamma(30-70 Hz)',...
                    ;'Beta/Theta',...
                    ;'Alpha/Beta',...
                    ;'Theta/Alpha',...
                    ;'Alpha+Beta+Gamma',...
                    ;'Theta/Beta',...
                    ;'Beta/(Theta+Alpha)',...
                    ;'Alpha/Gamma'};
     %% FeatureImportance
    feature_rank=Feature_selection_control(Model(2,:),'Random Forest');
    Table_Permu=feature_rank{1};
    Table_Gini=feature_rank{2};
    Feature_score.Gini{i,j}=Table_Gini;
    Feature_score.Permu{i,j}=Table_Permu;
    %% Caculate Accuracy,Recall,F1 score
    % Model SVM
    accuracy_1= trace(cm1{end})/sum(cm1{end},'all')*100;
    precision_1= cm1{end}(4)/(cm1{end}(3)+cm1{end}(4))*100;
    recall_1=cm1{end}(4)/(cm1{end}(2)+cm1{end}(4))*100;
    F1_1=2*precision_1* recall_1/( precision_1+recall_1);
    % Model RF
    accuracy_2= trace(cm2{end})/sum(cm2{end},'all')*100;
    precision_2= cm2{end}(4)/(cm2{end}(3)+cm2{end}(4))*100;
    recall_2=cm2{end}(4)/(cm2{end}(2)+cm2{end}(4))*100;
    F1_2=2*precision_2* recall_2/( precision_2+recall_2);

    model_performace_1=[accuracy_1',precision_1',recall_1',F1_1'];
    model_performace_2=[accuracy_2',precision_2',recall_2',F1_2'];
    %% Save Statical value
    Table_1=table(accuracy_1',precision_1',recall_1',F1_1');
    Table_1.Properties.VariableNames = {'Accuracy','Precision','Recall','F1'};
    Table_2=table(accuracy_2',precision_2',recall_2',F1_2');
    Table_2.Properties.VariableNames = {'Accuracy','Precision','Recall','F1'};
%     %% Save data
%     writetable(Table_1,fullfile(path_save,[subject_id,'_SVM_Stat.xlsx']),'Sheet',['Sheet',num2str(j)]);
%     writetable(Table_2,fullfile(path_save,[subject_id,'_RF_Stat.xlsx']),'Sheet',['Sheet',num2str(j)]);
    %% Save Model
    saveCompactModel(Model{1,min(i_fold_best_1)},[path_save_figure,'_SVM_Model']);
    saveCompactModel(Model{2,min(i_fold_best_2)},[path_save_figure,'_RF_Model']);

    %% Save Global table
    Table_1.Subject_id=repmat(subject_id,height(Table_1),1);
    Table_1.Channel=repmat(['Channel ',num2str(j)],height(Table_1),1);

    Table_2.Subject_id=repmat(subject_id,height(Table_2),1);
    Table_2.Channel=repmat(['Channel ',num2str(j)],height(Table_1),1);

    Table_model_1=[Table_model_1;Table_1];
    Table_model_2=[Table_model_2;Table_2];
%% Clear variable
    end

end
%% Prepare Model path save
folder_save_model=strsplit(folder_save,'\');
window_name=folder_save_model{end};
c_name=folder_save_model{end-1};
folder_save_model=fullfile(folder_save_model{1:end-2});
% %% Save for each model
% writetable(Table_model_1,fullfile(folder_save_model,[window_name,'Summary_SVM_Stat.xlsx']));
% writetable(Table_model_2,fullfile(folder_save_model,[window_name,'Summary_RF_Stat.xlsx']));
%% Summary 2 model
Table_model_1.Model=repmat('SVM',height(Table_model_1),1);
Table_model_2.Model=repmat('RF ',height(Table_model_2),1);
Table_model=[Table_model_1;Table_model_2];
%% Save all model
path_save_table=fullfile(folder_save_model,c_name,[window_name,'_',num2str(length(data)),'_Summary_Model.xlsx']);
writetable(Table_model,path_save_table);
%% Save Feature Importance
path_feature_index=fullfile(folder_save_model,c_name,[window_name,'_',num2str(length(data)),'_Feature_Importance.mat']);
Feature_score.name=feature_header;
save(path_feature_index,'Feature_score');
beep
