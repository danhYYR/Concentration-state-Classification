%% Prepare
close all;clc;clear all;
addpath('..\Function');
addpath('..\Function\Wavelet');
addpath('..\Function\codes_PHYSIONET_DATA');
addpath('..\Function\FourierTransform');

%% Load file
% Run this to load file
[folder,name,ext]=Loadfile();

if iscell(name)
    path=[folder{i},'\',name{i}];
    disp(name{i});
else
    path=[folder,'\',name];
    disp(name);
end
load(path);
%% Feturea extraction
channel_i=6;
fs=500;
% Power spectrum 
delta=[0.5 4];
theta=[4 13];
alpha=[8 13];
beta=[13 30];
window_length=3;
sample_num=1*5*(channel_i);
p_all=zeros(1,sample_num);
p_beta=zeros(1,sample_num);
p_theta=zeros(1,sample_num);
p_alpha=zeros(1,sample_num);
p_delta=zeros(1,sample_num);
p_gamma=zeros(1,sample_num);
for j=1:channel_i
    channel_name=['channel',num2str(j)];
    filtered=filtered_save.(channel_name);
    for i=1:length(filtered)/(window_length*fs)
        [p,f]=pspectrum(filtered(i:window_length*fs,:),fs);
        p_all(i,1+5*(j-1):5+5*(j-1))=sum(p);
        p_beta_i=find(13<f&f>30);
        p_beta(i,1+5*(j-1):5+5*(j-1))=sum(p(p_beta_i,:));
        p_theta_i=find(4<f&f>8);
        p_theta(i,1+5*(j-1):5+5*(j-1))=sum(p(p_theta_i,:));
        p_alpha_i=find(8<f&f>13);
        p_alpha(i,1+5*(j-1):5+5*(j-1))=sum(p(p_alpha_i,:));
        p_delta_i=find(0.5<=f&f<=4);
        p_delta(i,1+5*(j-1):5+5*(j-1))=sum(p(p_delta_i,:));
        p_gamma_i=find(30<=f&f<=70);
        p_gamma(i,1+5*(j-1):5+5*(j-1))=sum(p(p_gamma_i,:));
        % Alpha/all
        p_ratio_alpha_all=sum(p_alpha)./sum(p_all);
        p_ratio_alpha_all=p_ratio_alpha_all(find(~isnan(p_ratio_alpha_all)));
        % Beta/all
        p_ratio_beta_all=sum(p_beta)./sum(p_all);
        p_ratio_beta_all=p_ratio_beta_all(find(~isnan(p_ratio_beta_all)));
        % Theta/all
        p_ratio_theta_all=sum(p_theta)./sum(p_all);
        p_ratio_theta_all=p_ratio_theta_all(find(~isnan(p_ratio_theta_all)));
        % Delta/all
        p_ratio_delta_all=sum(p_delta)./sum(p_all);
        p_ratio_delta_all=p_ratio_delta_all(find(~isnan(p_ratio_delta_all)));
        p_ratio_gamma_all=sum(p_delta)./sum(p_all);
        p_ratio_gamma_all=p_ratio_gamma_all(find(~isnan(p_ratio_gamma_all)));
    end
end
name_split=strsplit(name,'_');
if strcmp(name_split{end},'concentration')
        if ~exist('p_concentration')
            assignin('base','p_concentration',[p_ratio_delta_all;p_ratio_theta_all;p_ratio_alpha_all;p_ratio_beta_all;p_ratio_gamma_all]');
        else
            p_concentration=[p_concentration;[p_ratio_delta_all;p_ratio_theta_all;p_ratio_alpha_all;p_ratio_beta_all;p_ratio_gamma_all]'];
        end
end
if strcmp(name_split{end},'rest')
    if ~exist('p_rest')
        assignin('base','p_rest',[p_ratio_delta_all;p_ratio_theta_all;p_ratio_alpha_all;p_ratio_beta_all;p_ratio_gamma_all]');
    else
        p_rest=[p_rest;[p_ratio_delta_all;p_ratio_theta_all;p_ratio_alpha_all;p_ratio_beta_all;p_ratio_gamma_all]'];
    end
end
%%
if exist('p_rest') && exist('p_concentration')
        if length(p_rest)==length(p_all)
            p_gr=[ones(length(p_concentration),1);zeros(length(p_rest),1)];
            p_data=[p_concentration;p_rest];
        end
    end
%% group scatter
if exist('p_data')
    n=length(p_data);
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
end