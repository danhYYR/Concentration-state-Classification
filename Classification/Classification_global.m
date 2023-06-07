close all;clc;clear all;
run('..\Function\load_function.m')
%% Run this to load file
path_file='..\Data_save\Feature_extraction\Self_accquistion';
[folder,name,ext]=Loadfile('.mat',path_file);
% Getpath save
if ~exist('folder_save')
    folder_save=uigetdir('..\Data_save\Result\Classification\Self-accquistion\Thesis','Choose where do you want to save');
end
%% Get path
path_data=fullfile(folder,[name,ext]);
%% LoadEEG
p_data=load(path_data);
p_data=p_data.p_global;
p_data=struct2cell(p_data)';
i_channel=[2 5];
feature=[4];
subject_id='Global';
subject_train=[1:size(p_data,1)-2];

%% Run build model
for j=1:length(i_channel)
    %% Prepare save name
    channel_name=['channel',num2str(i_channel(j))];
    path_save=fullfile(folder_save,subject_id);
    % Create folder to save
    mkdir (path_save)
    path_save_figure=[path_save,'\'];
    name_save=['Channel_2_5_Feature_',num2str(feature)];
    %% Prepare feature
    data=vertcat(p_data{subject_train,i_channel(j)});
    label={'Rest','Concentration'};
    value_label=[-1,0];
    p_gr=vertcat(p_data{subject_train,end});
    data(:,end+1)=p_gr;
    % Get label
    p_label=categorical(data(:,end),value_label,label);
    % Create train and test set
    i_remove=find(data(:,end)==1);
    data(i_remove,:)=[];
    p_gr(i_remove,:)=[];
    p_label(i_remove,:)=[];
    % Data with best feature
    data_feature(:,j)=data(:,feature);

end
    %% Create validation
    n=length(data);
    k=10;
%     c = cvpartition(p_gr,'LeaveOut');   
% Create k-fold validatetion
    c = cvpartition(p_gr,'KFold',k);   
    predict_model1=nan*ones(ceil(length(data)/k),c.NumTestSets);
    predict_model2=nan*ones(ceil(length(data)/k),c.NumTestSets);
    %% Train and test model
    for k=1:c.NumTestSets
        train_i=training(c,k);
        test_i=test(c,k);
        y_train = data(train_i,end);        % y train
        x_train = data_feature(train_i,:);    % get x_train
        y_test{k} = data(test_i,end);          % y test
        x_test = data_feature(test_i,:);      % get x_test;
        %% Classification with SVM
        t = templateSVM('Standardize',true,'KernelFunction','RBF');
        Md1 = fitcecoc(x_train,y_train,'Learners',t); 
        % Test data
        predict_model1(1:length(y_test{k}),k)=predict(Md1,x_test);
        acc_model1(k)= sum(predict_model1(1:length(y_test{k}),k)== y_test{k})/length(y_test{k})*100;
        %% Classification with RF
        Md2=fitensemble(x_train,y_train,'Bag',100,'Tree','Type','classification');
        predict_model2(1:length(y_test{k}),k)=predict(Md2,x_test);
        acc_model2(k)=sum(predict_model2(1:length(y_test{k}),k)==y_test{k})/length(y_test{k})*100;
        Model{1,k}=Md1;
        Model{2,k}=Md2;
    end
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
%         heatmap(label,label,cm1{end});
        confusionchart(y_actual,predict_label1,'ColumnSummary','total-normalized','RowSummary','total-normalized');
        title('Confusion matrix with SVM Model')
        subplot(2,1,2)
        cm2{k+1}=confusionmat(y_actual,predict_label2);
%         heatmap(label,label,cm2{end});
        confusionchart(y_actual,predict_label2,'ColumnSummary','total-normalized','RowSummary','total-normalized');
        title('Confusion matrix with RF model')
        %% Save cfs matrix
        set(gcf,'WindowState','maximized');
        saveas(gcf,[path_save_figure,name_save,'_Allsample_cfsmatrix.bmp']);
        close all
        %% Save Model
        saveCompactModel(Model{1,min(i_fold_best_1)},[path_save_figure,name_save,'_SVM_Model']);
        saveCompactModel(Model{2,min(i_fold_best_2)},[path_save_figure,name_save,'_RF_Model']);
%% Visulize with RF
figure;
gscatter(data_feature(:,1),data_feature(:,2),p_gr,'rb','.');
% Find decision boundary
x_grid= get(gca,'xlim');
x_grid(1)=fix(x_grid(1));
y_grid=get(gca,'ylim');
[grid1 grid2]=meshgrid([x_grid(1):0.01:x_grid(2)],[y_grid(1):0.01:y_grid(2)]);
grid= [grid1(:),grid2(:)];
Model_best1=Model{1,find(acc_model1==max(acc_model1))};
[~,score1]=predict(Model_best1,grid);
% Draw with contourf
contourf(grid1,grid2,reshape(score1(:,2),size(grid1)),'LineWidth',0.01);
colormap(gca,([255 200 200;200 200 255]./255))
axis([min(data_feature(:,1)) max(data_feature(:,1)) min(data_feature(:,2)) max(data_feature(:,2))])
hold on;
h(1:2)=gscatter(data_feature(:,1),data_feature(:,2),p_gr,'rb','.');
% Legend figure
legend(h,'Rest','Concentration','Location','northeast');
title('Decision Boundary for SVM')
hold off
%% Visulize with RF
figure;
gscatter(data_feature(:,1),data_feature(:,2),p_gr,'rb','.');
% Find decision boundary
x_grid= get(gca,'xlim');
x_grid(1)=fix(x_grid(1));
y_grid=get(gca,'ylim');
[grid1 grid2]=meshgrid([x_grid(1):0.01:x_grid(2)],[y_grid(1):0.01:y_grid(2)]);
grid= [grid1(:),grid2(:)];
Model_best2=Model{2,find(acc_model1==max(acc_model1))};
[~,score1]=predict(Model_best2,grid);
% Draw with contourf
contourf(grid1,grid2,reshape(score1(:,2),size(grid1)),'LineWidth',0.01);
colormap(gca,([255 200 200;200 200 255]./255))
axis([min(data_feature(:,1)) max(data_feature(:,1)) ...
      min(data_feature(:,2)) max(data_feature(:,2))])
hold on;
h(1:2)=gscatter(data(:,min(feature)),data(:,max(feature)),p_gr,'rb','.');
% Legend figure
legend(h,'Rest','Concentration','Location','northeast');
title('Decision Boundary for RF')
hold off

