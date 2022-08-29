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
% Run this to load file
if iscell(name)
    path=[folder{i},'\',name{i}];
    disp(name{i});
    sample_file=length(name);
else
    path=[folder,'\',name];
    disp(name);
    sample_file=1;
end
load(path);
n=length(data);
rand_num = randperm(size(data,1));
p_data=data(rand_num,1:end-1);
% Beta/Theta
p_data(:,6)=p_data(:,4)./p_data(:,2);
% Alpha/Beta
p_data(:,7)=p_data(:,3)./p_data(:,4);
% Theta/Alpha
p_data(:,8)=p_data(:,2)./p_data(:,3);
% Sum Alpha Beta Gamma
p_data(:,9)=sum(p_data(:,3:5),2);
p_gr=data(rand_num,end);
c = cvpartition(p_gr,'k',5);   % Create k-fold validatetion
%% Train and test model
for i=1:c.NumTestSets
    train_i=training(c,i);
    test_i=test(c,i);
    y_train = p_gr(train_i);    % y train
    x_train = p_data(train_i,:);  % get x_train
    y_test = p_gr(test_i);         % y test
    x_test = p_data(test_i,:);           % get x_test
    % %% Feature Selection
    % opts = statset('Display','iter');
    % fun = @(x_test,y_test,x_train,y_train)loss(fitcecoc(x_test,y_test),x_test,y_test);
    % [fs,history] = sequentialfs(fun,x_train,y_train,'cv',c,'options',opts)
    %% Classification with SVM
    feature=[2 4];
    Md1 = fitcsvm(x_train(:,feature),y_train,'KernelFunction','rbf'); 
    % Test data
    predict_model1(:,i)=predict(Md1,x_test(:,feature));
    acc_model1(i)= sum(predict_model1(:,i)== y_test)/length(y_test)*100;
    Md2=fitensemble(x_train(:,feature),y_train,'Bag',100,'Tree','Type','classification');
    predict_model2(:,i)=predict(Md2,x_test(:,feature));
    acc_model2(i)=sum(predict_model2(:,i)==y_test)/length(y_test)*100;
    Model{1,i}=Md1;
    Model{2,i}=Md2;
end
mean(acc_model1)
mean(acc_model2)
%% Confusion matrix chart
figure
for i=1:c.NumTestSets
    y_test= p_gr(test_i);
    subplot(c.NumTestSets,2,2*i-1)
    title(['Confusion matrix of SVM ',num2str(i)]);
    cm1{i}=confusionchart(y_test,predict_model1(:,i));
    subplot(c.NumTestSets,2,2*i)
    title(['Confusion matrix of SVM ',num2str(i)]);
    cm2{i}=confusionchart(y_test,predict_model2(:,i));
end
%% SVM regression

%% Visulize
figure;
h(1:2)=gscatter(p_data(:,min(feature)),p_data(:,max(feature)),p_gr,'rb','.');
hold on;
x_grid= get(gca,'xlim');
y_grid=get(gca,'ylim');
[grid1 grid2]=meshgrid([x_grid(1):0.01:x_grid(2)],[y_grid(1):0.01:y_grid(2)]);
grid= [grid1(:),grid2(:)];
[~,score1]=predict(Model{1,find(acc_model1==max(acc_model1))},grid);
h(3)=contour(grid1,grid2,reshape(score1(:,2),size(grid1)),[0 0],'k');
legend(h,{'Rest','Concentration','Support Vector'});
hold on
gscatter(grid(:,1),grid(:,2),score1);
%% decision plane

figure;
h1=gscatter(p_data(:,min(feature)),p_data(:,max(feature)),p_gr);
XLIMs = get(gca,'xlim');
YLIMs = get(gca,'ylim');
[xi,yi] = meshgrid([XLIMs(1):0.01:XLIMs(2)],[YLIMs(1):0.01:YLIMs(2)]);
dd = [xi(:), yi(:)];
pred_mesh = predict(Model{1,find(acc_model1==max(acc_model1))}, dd);
redcolor = [1, 0.8, 0.8];
bluecolor = [0.8, 0.8, 1];
pos = find(pred_mesh == 0);
h3 = plot(dd(pos,1), dd(pos,2),'s','color',redcolor,'Markersize',5,'MarkerEdgeColor',redcolor,'MarkerFaceColor',redcolor);
pos = find(pred_mesh == 1);
h4 = plot(dd(pos,1), dd(pos,2),'s','color',bluecolor,'Markersize',5,'MarkerEdgeColor',bluecolor,'MarkerFaceColor',bluecolor);
% uistack(h3,'bottom');
% uistack(h4,'bottom');