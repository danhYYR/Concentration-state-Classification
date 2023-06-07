%% Prepare
close all;clc;clear all;
run('..\Function\load_function.m')
%% Load file
path_file='..\Data_save\Filtered\Self_accquistion\Thesis';
[folder,name,ext]=Loadfile('.csv',path_file);
%% Meta data based on dataset
channel_min=1;
channel_i=6;
fs=500;
label='label';
% Sement data following window (Unit second)
duration_event=30;
% The duration 1 one epoch lenght unit second
i_sample=3;
%% Create nan struct with column is num of power feature (delta-theta-alpha-beta-gamma)
% Duration/i_sample is the num of epoch in one trial
if iscell(name)
    for j=1:channel_i
        channel_name=['channel',num2str(j)];
        % rest
        p_rest.(channel_name)=nan*ones(length(name)*(duration_event/i_sample),5);
        % concentration
        p_concentration.(channel_name)=nan*ones(length(name)*(duration_event/i_sample),5);
        % concentration high
        p_concentration_high.(channel_name)=nan*ones(length(name)*(duration_event/i_sample),5);
        % feature extraction for all file
        p_feature.(channel_name)=nan*ones(length(name)*(duration_event/i_sample),5);
    end
    % Label
    p_rest.(label)=-1*ones(length(name)*(duration_event/i_sample),1);
    p_concentration.(label)=0*ones(length(name)*(duration_event/i_sample),1);
    p_concentration_high.(label)=ones(length(name)*(duration_event/i_sample),1);
end
%% Load data
for i=1:length(name)
    if iscell(name)
        path=[folder{i},'\',name{i},ext{i}];
        disp(name{i});
        sample_file=length(name);
    else
        path=[folder,'\',name,ext];
        disp(name);
        sample_file=1;
    end
    %% Load data and modify data based on epoch length
    data=load(path);
    % Row limit based on epoch length
    n_limit=floor(duration_event/i_sample);
    if isstruct(data)

        filtered_save=data.('filtered')(1:n_limit*i_sample*fs,:);
    else
        filtered_save=data(1:n_limit*i_sample*fs,:);
    end
   

    %% Feturea extraction
    % Power spectrum 
    delta=[2 4];
    theta=[4 13];
    alpha=[8 13];
    beta=[13 30];
    for j=channel_min:channel_i
        channel_name=['channel',num2str(j)];
        filtered=reshape(filtered_save(:,j),[i_sample*fs],[]);
%         [p,f]=pspectrum(filtered,fs);
        [p,f]=periodogram(filtered,[],[],fs);
%         [p f]=fft_function(filtered,fs,"Power");
        % Feature of interesting
        i_p_all=find(2<=f&f<=40);
        p_all=sum(p(i_p_all,:));
        
        % Index Delta
        i_p_delta=find(2<f&f<=4);
        p_delta=sum(p(i_p_delta,:));
        % Index Theta
        i_p_theta=find(4<f&f<=8);
        p_theta=sum(p(i_p_theta,:));
        % Index Alpha
        i_p_alpha=find(8<f&f<=13);
        p_alpha=sum(p(i_p_alpha,:));
        % Index Beta
        i_p_beta=find(13<f&f<=30);
        p_beta=sum(p(i_p_beta,:));
        % Index Gamma
        i_p_gamma=find(30<f&f<=70);
        p_gamma=sum(p(i_p_gamma,:));
        % Get the power following band
        % Delta/all
        p_ratio_delta_all=p_delta./p_all;
        % Theta/all
        p_ratio_theta_all=p_theta./p_all;
        % Alpha/all
        p_ratio_alpha_all=p_alpha./p_all;
        % Beta/all
        p_ratio_beta_all=p_beta./p_all;
        % Gamma/all
        p_ratio_gamma_all=p_gamma./p_all;
        % P_feature following channel
        p_feature.(channel_name)=[p_ratio_delta_all;p_ratio_theta_all;p_ratio_alpha_all;p_ratio_beta_all;p_ratio_gamma_all]';
        
        % Assignin variable based on file name
        label=get_label(path);
        switch(label)
            case 0
                p_concentration.(channel_name)(1+(i-1)*(duration_event/i_sample):i*(duration_event/i_sample),:)=p_feature.(channel_name);
            case 1
                p_concentration_high.(channel_name)(1+(i-1)*(duration_event/i_sample):i*(duration_event/i_sample),:)=p_feature.(channel_name);
            case -1
                p_rest.(channel_name)(1+(i-1)*(duration_event/i_sample):i*(duration_event/i_sample),:)=p_feature.(channel_name);
            otherwise
                disp("Label error"); 
                break;
        end
        if ~iscell(name)
            break;
        end
    end
end
%% Create p_data
fields=fieldnames(p_rest);
[i_nan_rest,col]=find(isnan(p_rest.(channel_name)));
[i_nan_concentration,col]=find(isnan(p_concentration.(channel_name)));
[i_nan_concentration_high,col]=find(isnan(p_concentration_high.(channel_name)));
for i=1:length(fields)
    p_rest.(fields{i})(i_nan_rest,:)=[];
    p_concentration.(fields{i})(i_nan_concentration,:)=[];
    p_concentration_high.(fields{i})(i_nan_concentration_high,:)=[];
    p_data.(fields{i})=[p_concentration.(fields{i});p_concentration_high.(fields{i});p_rest.(fields{i})];
end
%% Check to save
if exist('p_data')
    if ~exist('folder_save')
        folder_save=uigetdir('..\Data_save\Feature_extraction\Reference\EEG_ET_simoulous');
    end
    %% Save 
    save([folder_save,'\Power Feature.mat'],'p_data');
end