% Add path
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
% Beta/Delta
p_data(:,10)=p_data(:,4)./p_data(:,1);
p_gr=data(rand_num,end);
%% group scatter
figure;
subplot(5,1,1)
plot([1:n/2],p_data(find(p_gr==1),1),'r',[1:n/2],p_data(find(p_gr==0),1),'b');
title('Data plot with 1 feature')
xlabel('Sample');
ylabel('Delta')
legend('Concentration','Rest');
subplot(5,1,2)
plot([1:n/2],p_data(find(p_gr==1),2),'r',[1:n/2],p_data(find(p_gr==0),2),'b');
title('Data plot with 1 feature')
xlabel('Sample');
ylabel('Theta')
legend('Concentration','Rest');
subplot(5,1,3)
plot([1:n/2],p_data(find(p_gr==1),3),'r',[1:n/2],p_data(find(p_gr==0),3),'b');
title('Data plot with 1 feature')
xlabel('Sample');
ylabel('Alpha')
legend('Concentration','Rest');
subplot(5,1,4)
plot([1:n/2],p_data(find(p_gr==1),4),'r',[1:n/2],p_data(find(p_gr==0),4),'b');
title('Data plot with 1 feature')
xlabel('Sample');
ylabel('Beta')
legend('Concentration','Rest');
subplot(5,1,5)
plot([1:n/2],p_data(find(p_gr==1),5),'r',[1:n/2],p_data(find(p_gr==0),5),'b');
title('Data plot with 1 feature')
xlabel('Sample');
ylabel('Gamma')
legend('Concentration','Rest');
%% Ratio
figure;
subplot(5,1,1)
plot([1:n/2],p_data(find(p_gr==1),6),'r',[1:n/2],p_data(find(p_gr==0),6),'b');
title('Data plot with 1 feature')
xlabel('Sample');
ylabel('Beta/Theta')
legend('Concentration','Rest');
subplot(5,1,2)
plot([1:n/2],p_data(find(p_gr==1),7),'r',[1:n/2],p_data(find(p_gr==0),8),'b');
title('Data plot with 1 feature')
xlabel('Sample');
ylabel('Alpha/Beta')
legend('Concentration','Rest');
subplot(5,1,3)
plot([1:n/2],p_data(find(p_gr==1),8),'r',[1:n/2],p_data(find(p_gr==0),8),'b');
title('Data plot with 1 feature')
xlabel('Sample');
ylabel('Theta/Alpha')
legend('Concentration','Rest');
subplot(5,1,4)
plot([1:n/2],p_data(find(p_gr==1),9),'r',[1:n/2],p_data(find(p_gr==0),9),'b');
title('Data plot with 1 feature')
xlabel('Sample');
ylabel('Alpha+Beta+Gamma')
legend('Concentration','Rest');
subplot(5,1,5)
plot([1:n/2],p_data(find(p_gr==1),10),'r',[1:n/2],p_data(find(p_gr==0),10),'b');
title('Data plot with 1 feature')
xlabel('Sample');
ylabel('Beta/Delta')
legend('Concentration','Rest');