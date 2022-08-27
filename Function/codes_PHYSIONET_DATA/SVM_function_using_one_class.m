function labels = SVM_function_using_one_class(x_train,y_train,labels_train)
% This function use Support Vector Machine to classify two classes in
% One Demensional Cordinate, using One-Class Learning
% x_train: vector x use for training
% y_train: vecotr y use for training
% Note: - the length of x_train must equal y_train
% x_test: vector x use for testing
% Y_train: vecotr y use for testing
% Note: - the length of x_test must equal y_test
%y_test=y_test';
X=[x_train',y_train];
y=labels_train; % for almost cases
%X1=x_test;
%X2=y_test;
rng(1); % For reproducibility
SVMModel = fitcsvm(X,y,'KernelScale','auto','Standardize',true,...
    'OutlierFraction',0.05);
svInd = SVMModel.IsSupportVector;
h = 0.02; % Mesh grid step size
[X1,X2] = meshgrid(min(X(:,1)):h:max(X(:,1)),...
    min(X(:,2)):h:max(X(:,2)));
[~,score] = predict(SVMModel,[X1(:),X2(:)]);
scoreGrid = reshape(score,size(X1,1),size(X2,2));

figure
plot(X(:,1),X(:,2),'k.')
hold on
plot(X(svInd,1),X(svInd,2),'ro','MarkerSize',10)
%contour(X1,X2,scoreGrid)
colorbar;
title('{\bf Threshold Detection via One-Class SVM}')
xlabel('Sepal Length (cm)')
ylabel('Sepal Width (cm)')
legend('Observation','Support Vector')
hold off

CVSVMModel = crossval(SVMModel);
[~,scorePred] = kfoldPredict(CVSVMModel);
outlierRate = mean(scorePred<0)