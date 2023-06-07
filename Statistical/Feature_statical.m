close all;clc;clear all;
run('..\Function\load_function.m')
%% Run this to load file
path_file='..\Data_save\Feature_extraction\Self_accquistion';
[folder,name,ext]=Loadfile('.mat',path_file);
%% Get path
path_data=fullfile(folder,[name,ext]);
%% LoadEEG Feature
p_data=load(path_data);
p_data=p_data.p_global;
p_data=struct2cell(p_data)';
i_channel=size(p_data,2)-1;
feature=[1:12];
subject_id='Global';
subject_train=[5];
%% Loop over each subfolder and process its files
for i=1:size(subject_train,1)
%%
% i_error=8;
% for i = i_error:i_error
    % Get name_subject file
    % Get a list of all files in the subfolder
    for j=1:size(p_data,2)
        channel_name=['Channel',num2str(j)];
        %% Prepare feature
        data=vertcat(p_data{subject_train(i),j});
        label={'Rest','Concentration'};
        value_label=[-1,0];
        p_gr=vertcat(p_data{subject_train(i),end});
        % Get label
        p_label=categorical(data(:,end),value_label,label);
        % Create train and test set
        i_remove=find(p_gr==1);
        data(i_remove,:)=[];
        p_gr(i_remove,:)=[];
        p_label(i_remove,:)=[];

        %% Get statistical feature with min - mean - median- max (concentraion - rest)
        i_concentration=find(p_gr==0);
        i_rest=find(p_gr==-1);
        i_concentration_high=find(p_gr==1);
        p_label=categorical(data(:,end),value_label,label);
        feature_statistical(:,1)=min(data(i_concentration,:));
        feature_statistical(:,2)=min(data(i_rest,:));
        feature_statistical(:,3)=mean(data(i_concentration,:));
        feature_statistical(:,4)=mean(data(i_rest,:));
        feature_statistical(:,5)=median(data(i_concentration,:));
        feature_statistical(:,6)=median(data(i_rest,:));
        feature_statistical(:,7)=max(data(i_concentration,:));
        feature_statistical(:,8)=max(data(i_rest,:));
        statistical.(channel_name)=feature_statistical;
    end
end
%% Save with excel
    if ~exist('folder_save')
        folder_save=uigetdir;
    end
    path_save=[folder_save,'\','Feature Statistical.xlsx'];
%% Prepare header
statistical_header={'Feature','Min Concentration','Min Rest',...
                    'Mean Concentration','Mean Rest',...
                    'Median Concentration','Median_Rest',...
                    'Max Concentration','Max Rest',...
                    };
statistical_feature={'Delta',...
                    ;'Theta',...
                    ;'Alpha',...
                    ;'Beta',...
                    ;'Gamma (30-70 Hz)',...
                    ;'Beta/Theta',...
                    ;'Alpha/Beta',...
                    ;'Theta/Alpha',...
                    ;'Alpha+Beta+Gamma',...
                    ;'Theta/Beta',...
                    ;'Beta/(Theta+Alpha)',...
                    ;'Alpha/Gamma'};
%% Write table for channel
for i=1:size(p_data,2)-1
    %% Run for channel i
    channel_name=['Channel',num2str(i)];
    statistical_data=statistical.(channel_name);
    %% Save feature statistical
    %% Convert data to cell 
    statistical_data=num2cell(round(statistical_data,4));
    %% Connect data into table demand
    table_save=vertcat(statistical_header,horzcat(statistical_feature,statistical_data));
    writecell(table_save,path_save,'Sheet',['Sheet',num2str(i)]);
    %% Save Tau cross correlation
%     channel_name=['channel',num2str(i)];
%     statistical_data=feature_cross_tau.(channel_name);
%     statistical_data=num2cell(round(statistical_data,4));
%     statiscal_tau_header=vertcat('Feature',statistical_feature);
%     statiscal_tau_data=vertcat(statistical_feature',statistical_data );
    writecell(table_save,[folder_save,'\Tau_cross.xlsx'],'Sheet',['Sheet',num2str(i)]);
end