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
name_file=strsplit(folder,'\');
i_name_file=9;
%% Run this to load file
% disp(name_file{i_name_file});
sample_file=1;
load(path);
% Num channel
channel_i=2;
feature=[1 7];
% Channel get
channel=2;
    %% Prepare feature
    channel_name=['channel',num2str(channel)];
    data=p_data.(channel_name);
    label={'Rest','Concentration'};
    value_label=[-1,0];
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
    data(:,13)=p_gr;
    % Get label
    p_label=categorical(data(:,end),value_label,label);
    % Create train and test set
    i_remove=find(data(:,13)==1);
    data(i_remove,:)=[];
    p_gr(i_remove,:)=[];
    p_label(i_remove,:)=[];

    % rng(1);
     %% Create validation
    n=length(data);
    k=4;
    c = cvpartition(p_gr,'k',k);   % Create k-fold validatetion
    predict_model1=nan*ones(ceil(length(data)/k),c.NumTestSets);
    predict_model2=nan*ones(ceil(length(data)/k),c.NumTestSets);
%% Train and test model
for j=1:c.NumTestSets
    train_i=training(c,j);
    test_i=test(c,j);
    y_train = data(train_i,13);        % y train
    x_train = data(train_i,1:end-1);    % get x_train
    y_test = data(test_i,13);          % y test
    x_test = data(test_i,1:end-1);      % get x_test;
    y_actual=p_label(test_i);
    %% Classification with SVM
    Md1 = fitcsvm(x_train(:,feature),y_train,'KernelFunction','polynomia');
%         'RBF');  
%         'polynomia');
%         'linear');
    % Test data
    predict_model1(:,j)=predict(Md1,x_test(:,feature));
    acc_model1(j)= sum(predict_model1(:,j)== y_test)/length(y_test)*100;
    Md2=fitensemble(x_train(:,feature),y_train,'Bag',100,'Tree','Type','classification');
    predict_model2(:,j)=predict(Md2,x_test(:,feature));
    acc_model2(j)=sum(predict_model2(:,j)==y_test)/length(y_test)*100;
    Model{1,j}=Md1;
    Model{2,j}=Md2;
    
end
%% Visulize with RF
figure;
gscatter(data(:,min(feature)),data(:,max(feature)),p_gr,'rb','.');
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
axis([min((data(:,min(feature)))) max((data(:,min(feature)))) min((data(:,max(feature)))) max((data(:,max(feature))))])
hold on;
h(1:2)=gscatter(data(:,min(feature)),data(:,max(feature)),p_gr,'rb','.');
% Legend figure
legend(h,'Rest','Concentration','Location','northeast');
title('Decision Boundary for SVM')
hold off
%% Visulize with RF
figure;
gscatter(data(:,min(feature)),data(:,max(feature)),p_gr,'rb','.');
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
axis([min((data(:,min(feature)))) max((data(:,min(feature)))) min((data(:,max(feature)))) max((data(:,max(feature))))])
hold on;
h(1:2)=gscatter(data(:,min(feature)),data(:,max(feature)),p_gr,'rb','.');
% Legend figure
legend(h,'Rest','Concentration','Location','northeast');
title('Decision Boundary for RF')
hold off


