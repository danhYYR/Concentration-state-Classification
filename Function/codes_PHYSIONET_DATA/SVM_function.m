function labels = SVM_fucntion(x_train,y_train,labels_train,x_test,y_test)
% This function use Support Vector Machine to classify multiple classes in
% Two Demensional Cordinate
% x_train: vector x use for training
% y_train: vecotr y use for training
% Note: - the length of x_train must equal y_train
% x_test: vector x use for testing
% Y_train: vecotr y use for testing
% Note: - the length of x_test must equal y_test
% Some script code below can use for testing
% Example 1: Testing code for linear classifying in Binary Stages
    %x_train=[1 1 2 3 4 3 4 5 5 6];
    %y_train=[3 4 2 4 4 1 2 2 3 1];
    %X_train=[x_train',y_train'];
    %labels_train=[1 1 1 1 1 0 0 0 0 0];
    %Y=labels_train;
    %x_test=[2 5 3 2 3 0];
    %y_test=[5 0 0 1 1.8 0];
    %X_test=[x_test',y_test'];
    %Y_test=(1:length(X_test))';
    %rng(1); % For reproducibility
    %SVMModel = fitcsvm(X_train(:,:),Y(:),'Standardize',true,...'ClassNames',[true false]);
    %CompactSVMModel = compact(SVMModel);
    %whos('SVMModel','CompactSVMModel')
    %CompactSVMModel = fitPosterior(CompactSVMModel,...X_train(:,:),Y(:))
    %[labels,PostProbs] = predict(CompactSVMModel,X_test(:,:));
    %table(Y_test(:),labels,PostProbs(:,2),'VariableNames',...{'TrueLabels','PredictedLabels','PosClassPosterior'})

% Example 2: Testing code for non-linear classifying in Binary Stages
    %x_train=[1 1 2 3 4 3 4 5 5 6 2];
    %y_train=[3 4 2 4 4 1 2 2 3 1 3];
    %X_train=[x_train',y_train'];
    %labels_train=[1 1 1 1 1 0 0 0 0 0 0];
    %Y=labels_train;
    %x_test=[2 5 3 2 3 0];
    %y_test=[5 0 0 1 1.8 0];
    %X_test=[x_test',y_test'];
    %Y_test=(1:length(X_test))';
    %rng(1); % For reproducibility
    %SVMModel = fitcsvm(X_train(:,:),Y(:),'Standardize',true,...
        %'ClassNames',[true false]);
    %CompactSVMModel = compact(SVMModel);
    %whos('SVMModel','CompactSVMModel')
    %CompactSVMModel = fitPosterior(CompactSVMModel,...
        %X_train(:,:),Y(:))
    %[labels,PostProbs] = predict(CompactSVMModel,X_test(:,:));
    %table(Y_test(:),labels,PostProbs(:,2),'VariableNames',...
        %{'TrueLabels','PredictedLabels','PosClassPosterior'})
y_train=y_train';
y_test=y_test';
X_train=[x_train,y_train];
Y=labels_train';%for staging training
%Y=labels_train; % for almost cases
X_test=[x_test,y_test];
Y_test=(1:length(X_test))';
rng(1); % For reproducibility
SVMModel = fitcsvm(X_train(:,:),Y(:),'Standardize',true,...
    'ClassNames',[true false]);
CompactSVMModel = compact(SVMModel);
whos('SVMModel','CompactSVMModel')
CompactSVMModel = fitPosterior(CompactSVMModel,...
X_train(:,:),Y(:));
    [labels,PostProbs] = predict(CompactSVMModel,X_test(:,:));
table(Y_test(:),labels,PostProbs(:,2),'VariableNames',...
    {'TrueLabels','PredictedLabels','PosClassPosterior'})

