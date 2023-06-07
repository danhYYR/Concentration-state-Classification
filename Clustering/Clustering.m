% Add path
close all;clc;clear all;
addpath('..\Function');
addpath('..\Function\Wavelet');
addpath('..\Function\codes_PHYSIONET_DATA');
addpath('..\Function\FourierTransform');
% Feature: Delta-Theta-Alpha-Beta-Gamma in file mat
%% Load file
[folder,name,ext]=Loadfile();
path=[folder,'\',name];
%% Run this to load file
disp(name);
sample_file=1;
load(path);
channel_i=1;
%% Run for all channel
i=channel_i
%% Run for channel i
channel_name=['channel',num2str(i)];
data=vertcat(p_data.(channel_name));
label={'Rest','Concentration','High Concentration'};
value_label=[-1,0,1];
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
% Ratio Alpha/Gamma
data(:,12)=data(:,3)./data(:,5);
p_gr=[0*ones(length(data)/3,1);ones(length(data)/3,1);-1*ones(length(data)/3,1)];
p_label=categorical(data(:,end),value_label,label);
%% Validation split
feature=[1:12];
c = cvpartition(n,'Holdout',0.3);   
j=1
train_i=training(c,j);
test_i=test(c,j);
y_train = p_gr(train_i);        % y train
x_train = data(train_i,feature);    % get x_train
y_test = p_gr(test_i);          % y test
x_test = data(test_i,feature);      % get x_test
%% k-mean clustering
rng(1); % For reproducibility
[idx,C] = kmeans(x_train(:,[7]),3);
%% Plot and check
figure
gscatter([1:length(x_train)]',x_train(:,7),idx)
figure
gscatter([1:length(x_train)]',x_train(:,7),y_train)