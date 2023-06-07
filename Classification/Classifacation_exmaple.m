%% Prepare
close all;clc;clear all;
addpath('..\Function');
addpath('..\Function\Wavelet');
addpath('..\Function\codes_PHYSIONET_DATA');
addpath('..\Function\FourierTransform');
% %% Generate Data
% sample=1000;
% r1=2;
% r2=5;
% % Circle
% r_circle = r1*sqrt(rand(sample,1)); % Radius
% t_circle = r1*pi*rand(sample,1);  % Angle
% y_circle=ones(sample,1);
% % Random feature
% x1=randi(sample,1).*rand(2*sample,1);
% x2=randi(sample,1).*rand(2*sample,1);
% % Square
% r1_square = r2*rand(sample,1);
% r2_square = r2*rand(sample,1);
% y_square = zeros(sample,1);
% data=[[[r_circle.*cos(t_circle),r_circle.*sin(t_circle)];[r1_square,r2_square]],x1,x2];
% y=[y_circle;y_square];
%% Example dataset
load fisheriris
sample=length(meas);
x1=randi(sample,1).*rand(sample,1);
x2=randi(sample,1).*rand(sample,1);
data=[meas,x1,x2];
y=findgroups(species);

%% Plot
figure
subplot(1,2,1)
gscatter(data(:,1),data(:,2),y);
hold on
ezpolar(@(data)2);
subplot(1,2,2)
gscatter(data(:,3),data(:,4),y)
%% Classifiaction
feature=[1:6];
num_tree=100;
% Create validation
n=length(data);
k=5;
c = cvpartition(y,'k',k);   % Create k-fold validatetion
predict_model1=nan*ones(ceil(length(data)/k),c.NumTestSets);
predict_model2=nan*ones(ceil(length(data)/k),c.NumTestSets);
    % Train and test model
    for j=1:c.NumTestSets
        i_train=training(c,j);
        i_test=test(c,j);
        y_train = y(i_train);        % y train
        x_train = data(i_train,feature);    % get x_train
        y_test = y(i_test);          % y test
        x_test = data(i_test,feature);      % get x_test
        Md1 = fitensemble(x_train,y_train,'Bag',num_tree,'Tree','Type','classification');
        % Test data
        predict_model1(:,j)=predict(Md1,x_test);
        acc_model1(j)= sum(predict_model1(:,j)== y_test)/length(y_test)*100;    
        Model{1,j}=Md1;
    end
%% Confusion matrix chart
for j=1:c.NumTestSets
    i_test=test(c,j);
    y_test=y(i_test);
    figure('Name',['Fold', num2str(j)])
    cm1{j}=confusionmat(y_test,predict_model1(:,j));
    confusionchart(y_test,predict_model1(:,j));
    title('Confusion matrix with RF Model')
end
%% Plot Tree Cycle
i_Model_best=find(acc_model1==max(acc_model1));
rsLoss = resubLoss(Model{i_Model_best(1)},'Mode','Cumulative');
figure
plot(rsLoss);
xlabel('Number of Learning Cycles');
ylabel('Resubstitution Loss');