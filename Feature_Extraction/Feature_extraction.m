%% Prepare
close all;clc;clear all;
run('..\Function\load_function.m')
%% Run this to load file
path_file='..\Data_save\Segmentation\Self- accquistion\Thesis';
path_folder=uigetdir(path_file,'Choose folder to autoload');
% Getpath save
if ~exist('folder_save')
    folder_save=uigetdir('..\Data_save\Feature_extraction\Self_accquistion','Choose where do you want to save');
end
% Get a list of all subfolders in the root folder
subfolders = dir(path_folder);
subfolders = subfolders([subfolders(:).isdir] & ~ismember({subfolders(:).name}, {'.', '..'}));
%% Auto generate folder
for i=1:length(subfolders)
    % Extract the subject name from the file name
    name_subject=subfolders(i).name;
    mkdir(fullfile(folder_save,name_subject));
end
%% Loop over each subfolder and process its files
p_global=[];
for i = 1:length(subfolders)
% i_error=8;
% for i = i_error:i_error
    subfolder = subfolders(i);
    subfolderPath = fullfile(path_folder, subfolder.name);
    % Get name_subject file
    % Get a list of all files in the subfolder
    files = dir(fullfile(subfolderPath, '*.csv'));
    exp='(?<name>Subject\d+)_(?<session>\d*).csv$';
    %% Caculate at frequency domain
    p_power=powerfeatrue(files);
    %% Calculate for global
    p_global=[p_global;p_power];
    %% Check to save
    subject_id=subfolders(i).name;
    disp(subject_id);
    disp('Remain');
    disp(length(subfolders)-i);
    if exist('p_power')
        if ~exist('folder_save')
            folder_save=uigetdir('..\Data_save\Feature_extraction\');
        end
        %% Save 
        path_save=fullfile(folder_save,subject_id,'PowerFeature.mat');
        save(path_save,'p_power');
    end
end
    %% Save 
    path_save=fullfile(folder_save,'PowerFeature_Global.mat');
    save(path_save,'p_global');
beep
%% Power Feature
function p_power= powerfeatrue(name_subject)
    channel_i=6;
    label='label';
    fs=1000;
    % Sement power following window (Unit second)
    duration_event=120;
    % The duration 1 one epoch lenght unit second
    i_sample=15;
    channel_min=1;
    num_feature=14;
    if isstruct(name_subject)
        for j=1:channel_i
            channel_name=['channel',num2str(j)];
            % Multi sample
            % rest
            p_rest.(channel_name)=nan*ones(length(name_subject)*(duration_event/i_sample),num_feature);
            % concentration
            p_concentration.(channel_name)=nan*ones(length(name_subject)*(duration_event/i_sample),num_feature);
            % concentration high
            p_concentration_high.(channel_name)=nan*ones(length(name_subject)*(duration_event/i_sample),num_feature);
            % feature extraction for all file
            p_feature.(channel_name)=nan*ones(length(name_subject)*(duration_event/i_sample),num_feature);
% %           Welch method
%             % rest
%             p_rest.(channel_name)=nan*ones(length(name_subject),num_feature);
%             % concentration
%             p_concentration.(channel_name)=nan*ones(length(name_subject),num_feature);
%             % concentration high
%             p_concentration_high.(channel_name)=nan*ones(length(name_subject),num_feature);
%             % feature extraction for all file
%             p_feature.(channel_name)=nan*ones(length(name_subject),num_feature);
        end
        % Label
        p_rest.(label)=-1*ones(length(name_subject)*(duration_event/i_sample),1);
        p_concentration.(label)=0*ones(length(name_subject)*(duration_event/i_sample),1);
        p_concentration_high.(label)=ones(length(name_subject)*(duration_event/i_sample),1);
    end    
    %% Loop over each file and encode the subject name_subject
    for i = 1:length(name_subject)
        file = name_subject(i);
        fileName = file.name;
        path_power=fullfile(file.folder, fileName);
            %% LoadEEG
        power=load(path_power);
        % Row limit based on epoch length
        n_limit=floor(duration_event/i_sample);
        if isstruct(power)

            filtered_save=power.('filtered')(1:n_limit*i_sample*fs,:);
        else
            filtered_save=power(1:n_limit*i_sample*fs,:);
        end
        %% Feturea extraction
        % Power spectrum 
        delta=[2 4];
        theta=[4 13];
        alpha=[8 13];
        SMR=[13 15];
        beta_mid=[15 20];
        beta_high=[20 30];
        gamma=[30 40];
        channel_min=1;
        for j=channel_min:channel_i
            channel_name=['channel',num2str(j)];
            filtered=reshape(filtered_save(:,j),[i_sample*fs],[]);
%             filtered=filtered_save(:,j);

%             [p,f]=pspectrum(filtered,fs);
            [p,f]=periodogram(filtered,[],[],fs);
        %         [p f]=fft_function(filtered,fs,"Power");
%             [p,f]=pwelch(filtered,i_sample*fs,0,i_sample*fs,fs);
            % Feature of interesting
            i_p_all=find(2<=f&f<=40);
            p_all=sum(p(i_p_all,:));

            % Index Delta
            i_p_delta=find(0.5<f&f<=4);
            p_delta=sum(p(i_p_delta,:));
            % Index Theta
            i_p_theta=find(4<f&f<=8);
            p_theta=sum(p(i_p_theta,:));
            % Index Alpha
            i_p_alpha=find(8<f&f<=13);
            p_alpha=sum(p(i_p_alpha,:));
            % Index Beta
            % Index SMR
            i_p_SMR=find(13<f&f<=15);
            p_SMR=sum(p(i_p_SMR,:));
            i_p_beta_mid=find(15<f&f<=20);
            p_beta_mid=sum(p(i_p_beta_mid,:));
            i_p_beta_high=find(20<f&f<=30);
            p_beta_high=sum(p(i_p_beta_high,:));
            % Index Gamma
            i_p_gamma=find(30<f&f<=40);
            p_gamma=sum(p(i_p_gamma,:));
            % Get the power following band
            % Delta/all
            p_ratio_delta_all=p_delta./p_all;
            % Theta/all
            p_ratio_theta_all=p_theta./p_all;
            % Alpha/all
            p_ratio_alpha_all=p_alpha./p_all;
            % SMR/all
            p_ratio_SMR_all=p_SMR./p_all;
            % Beta/all
            p_ratio_beta_mid_all=p_beta_mid./p_all;
            p_ratio_beta_high_all=p_beta_high./p_all;
            % Gamma/all
            p_ratio_gamma_all=p_gamma./p_all;
            % P_feature following channel
            power=[p_ratio_delta_all;p_ratio_theta_all;p_ratio_alpha_all;p_ratio_SMR_all;p_ratio_beta_mid_all;p_ratio_beta_high_all;p_ratio_gamma_all]';
            %% Ratio feature
            % SMR+Mid Beta/Theta
            power(:,8)=sum(power(:,4:5),2)./power(:,2);
            % Alpha/Beta
            power(:,9)=power(:,3)./sum(power(:,4:6),2);
            % Theta/Alpha
            power(:,10)=power(:,2)./power(:,3);
            % Sum Alpha Beta Gamma
            power(:,11)=sum(power(:,3:6),2);
            % Ratio Theta/Beta
            power(:,12)=power(:,2)./sum(power(:,4:6),2);
            % Ratio Beta/(Alpha+Theta)
            power(:,13)=sum(power(:,4:6),2)./sum(power(:,2:3),2);
            % Ratio Alpha/Gamma
            power(:,14)=power(:,3)./power(:,5);
            p_feature.(channel_name)=power;
            % Assignin variable based on file name_subject
            label=get_label(path_power);
            i_range=1+(i-1)*(duration_event/i_sample):i*(duration_event/i_sample);
%             i_range=i;
            switch(label)
                case 0
                    p_concentration.(channel_name)(i_range,:)=p_feature.(channel_name);
                case 1
                    p_concentration_high.(channel_name)(i_range,:)=p_feature.(channel_name);
                case -1
                    p_rest.(channel_name)(i_range,:)=p_feature.(channel_name);
                otherwise
                    disp("Label error");   
            end
        end
    end
        %% Create p_power
    fields=fieldnames(p_rest);
    [i_nan_rest,col]=find(isnan(p_rest.(channel_name)));
    [i_nan_concentration,col]=find(isnan(p_concentration.(channel_name)));
    [i_nan_concentration_high,col]=find(isnan(p_concentration_high.(channel_name)));

    for i=1:length(fields)
        p_rest.(fields{i})(i_nan_rest,:)=[];
        p_concentration.(fields{i})(i_nan_concentration,:)=[];
        p_concentration_high.(fields{i})(i_nan_concentration_high,:)=[];
        p_power.(fields{i})=[p_concentration.(fields{i});p_concentration_high.(fields{i});p_rest.(fields{i})];
    end
end