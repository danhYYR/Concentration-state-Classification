%% Prepare
close all;clc;clear all;
addpath('..\Function');
addpath('..\Function\Wavelet');
addpath('..\Function\codes_PHYSIONET_DATA');
addpath('..\Function\FourierTransform');

%% Load file
[folder,name,ext]=Loadfile();
% Run this to load file
for i=1:length(name)
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
    channel_min=6;
    channel_i=6;
    segment=5;
    sample_num=sample_file*segment*(channel_i-channel_min+1);
    fs=500;
    window_length=3;
    p_all=zeros(1,sample_num);
    p_beta=zeros(1,sample_num);
    p_theta=zeros(1,sample_num);
    p_alpha=zeros(1,sample_num);
    p_delta=zeros(1,sample_num);
    p_gamma=zeros(1,sample_num);
    %% Feturea extraction
    % Power spectrum 
    delta=[0.5 4];
    theta=[4 13];
    alpha=[8 13];
    beta=[13 30];
    for j=channel_min:channel_i
        channel_name=['channel',num2str(j)];
        filtered=filtered_save.(channel_name);
        [p,f]=pspectrum(filtered,fs);
        p=Normalize(p);
        p_all(:,(i-1)*segment+1+segment*(j-1):(i-1)*segment+segment+segment*(j-1))=sum(p);
        p_beta_i=find(13<=f&f<=30);
        p_beta(:,(i-1)*segment+1+segment*(j-1):(i-1)*segment+segment+segment*(j-1))=sum(p(p_beta_i,:));
        p_theta_i=find(4<=f&f<=8);
        p_theta(:,(i-1)*segment+1+segment*(j-1):(i-1)*segment+segment+segment*(j-1))=sum(p(p_theta_i,:));
        p_alpha_i=find(8<=f&f<=13);
        p_alpha(:,(i-1)*segment+1+segment*(j-1):(i-1)*segment+segment+segment*(j-1))=sum(p(p_alpha_i,:));
        p_delta_i=find(0.5<=f&f<=4);
        p_delta(:,(i-1)*segment+1+segment*(j-1):(i-1)*segment+segment+segment*(j-1))=sum(p(p_delta_i,:));
        p_gamma_i=find(30<=f&f<=70);
        p_gamma(:,(i-1)*segment+1+segment*(j-1):(i-1)*segment+segment+segment*(j-1))=sum(p(p_gamma_i,:));
        % Alpha/all
        p_ratio_alpha_all=p_alpha./p_all;
        p_ratio_alpha_all=p_ratio_alpha_all(find(~isnan(p_ratio_alpha_all)));
        % Beta/all
        p_ratio_beta_all=p_beta./p_all;
        p_ratio_beta_all=p_ratio_beta_all(find(~isnan(p_ratio_beta_all)));
        % Theta/all
        p_ratio_theta_all=p_theta./p_all;
        p_ratio_theta_all=p_ratio_theta_all(find(~isnan(p_ratio_theta_all)));
        % Delta/all
        p_ratio_delta_all=p_delta./p_all;
        p_ratio_delta_all=p_ratio_delta_all(find(~isnan(p_ratio_delta_all)));
        p_ratio_gamma_all=p_delta./p_all;
        p_ratio_gamma_all=p_ratio_gamma_all(find(~isnan(p_ratio_gamma_all)));
    end
    p_ratio_delta_all(find(p_ratio_delta_all==0))=[];
    p_ratio_theta_all(find(p_ratio_theta_all==0))=[];
    p_ratio_alpha_all(find(p_ratio_alpha_all==0))=[];
    p_ratio_beta_all(find(p_ratio_beta_all==0))=[];
    p_ratio_gamma_all(find(p_ratio_gamma_all==0))=[];
    name_split=strsplit(path,'_');
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
    % Create group 
    if exist('p_rest') && exist('p_concentration')
        if length([p_rest;p_concentration])==sample_num
            p_gr=[ones(length(p_concentration),1);zeros(length(p_rest),1)];
            p_data=[p_concentration;p_rest];
        end
    end
    if ~iscell(name)
        break;
    end
end
%% Load 2 feature
    if exist('p_data')
        if ~exist('folder_save')
            folder_save=uigetdir;;
        end
        if iscell(name)
            path_save=[folder_save,'\',name{i}];
        else
            path_save=[folder,'\',name];
        end
    %% Save 
    data=[p_data,p_gr];
    save([folder_save,'\Channel ',num2str(channel_min),'_',num2str(channel_i),'.mat'],'data');
end