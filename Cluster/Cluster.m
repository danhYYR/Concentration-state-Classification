%% Prepare
close all;clc;clear all;
addpath('..\Function');
addpath('..\Function\Wavelet');
addpath('..\Function\codes_PHYSIONET_DATA');
addpath('..\Function\FourierTransform');
[folder,name,ext]=Loadfile();
%% Load file
% Run this to load file
for i=1:length(name)
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
    p_all=zeros(length(filtered_save.channel1)/(window_length*fs),5*channel_i);
    p_beta=zeros(length(filtered_save.channel1)/(window_length*fs),5*channel_i);
    p_theta=zeros(length(filtered_save.channel1)/(window_length*fs),5*channel_i);
    p_alpha=zeros(length(filtered_save.channel1)/(window_length*fs),5*channel_i);
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
        end
        p_ratio_alpha_all=sum(p_alpha)./sum(p_all);
        % Beta/all
        p_ratio_beta_all=sum(p_beta)./sum(p_all);
        % Theta/all
        p_ratio_theta_all=sum(p_theta)./sum(p_all);
        % Beta/Theta
        p_ratio_beta_theta=p_ratio_beta_all./p_ratio_theta_all;
        % Alpha/beta
        p_ratio_alpha_beta=sum(p_alpha)./sum(p_beta);
    end
    name_split=strsplit(path,'_');
    if strcmp(name_split{end},'concentration')
        assignin('base','p_concentration',[p_ratio_beta_all;p_ratio_theta_all;p_ratio_beta_theta;p_ratio_alpha_beta]');
    end
    if strcmp(name_split{end},'rest')
        assignin('base','p_rest',[p_ratio_beta_all;p_ratio_theta_all;p_ratio_beta_theta;p_ratio_alpha_beta]');
    end
    % Create group 
    if exist('p_rest')
        p_gr=[zeros(length(p_concentration),1);ones(length(p_rest),1)];
        p_data=[p_concentration;p_rest];
    end
    if ~iscell(name)
        break;
    end
end
%% Load 2 feature
%% Plot
if exist('p_data')
    figure;
    gscatter(p_data(:,1),p_data(:,2),p_gr);
    title('Data plot with 2 feature')
    xlabel('Ratio Beta and all');
    ylabel('Ratio Theta and all');
    figure;
    gscatter(p_data(:,3),p_data(:,4),p_gr);
    title('Data plot with 2 feature')
    xlabel('Ratio Beta and Theta');
    ylabel('Ratio Alpha and Beta');
    legend('Concentration','Rest');
    figure;
    gscatter(p_data(:,3),1./p_data(:,4),p_gr);
    title('Data plot with 2 feature')
    xlabel('Ratio Beta and Theta');
    ylabel('Ratio Beta and Alpha');
    legend('Concentration','Rest');
    figure;
    gscatter(p_data(:,3),zeros(length(p_data),1),p_gr);
    title('Data plot with 1 feature')
    xlabel('Ratio Beta and Theta');
    legend('Concentration','Rest');

    %% Clustering
    [idx,C] = kmeans([p_data(:,1),p_data(:,2)],2);
    x1 = min(p_data(:,1)):0.01:max(p_data(:,1));
    x2 = min(p_data(:,2)):0.01:max(p_data(:,2));
    figure;
    gscatter(p_data(:,1),p_data(:,2),idx);
    title('Data using k-mean-clustering')
end