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
%% Load data
disp(name);
sample_file=1;
load(path);
channel_i=2;
i=1;
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
p_gr=[ones(length(data)/2,1);-1*ones(length(data)/2,1)];
rng(1);
c = cvpartition(p_gr,'k',5);   % Create k-fold validatetion
%% Feature selection
% SVM model
opts = statset('display','iter');
classf = @(train_data, train_labels, test_data, test_labels)...
sum(predict(fitcsvm(train_data,train_labels,'KernelFunction','rbf'), test_data) ~= test_labels);
[fs, his] = sequentialfs(classf,data,p_gr,'cv',c,'options',opts,'nfeatures',2);
feature_best_1{i}=find(fs==1);
% RNN Model
classf = @(train_data, train_labels, test_data, test_labels)...
sum(predict(fitensemble(train_data,train_labels,'Bag',20,'Tree','Type','classification'), test_data) ~= test_labels);
[fs, his] = sequentialfs(classf,data,p_gr,'cv',c,'options',opts,'nfeatures',2);
feature_best_2{i}=find(fs==1);

