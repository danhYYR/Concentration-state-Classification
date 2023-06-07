close all;clc;clear all;
run('..\Function\load_function.m')
%% Run this to load file
path_file='..\Data_save\Feature_extraction\Self_accquistion';
[folder,name,ext]=Loadfile('.mat',path_file);
% Getpath save
if ~exist('folder_save')
    folder_save=uigetdir('..\Data_save\Result\Classification\Self-accquistion\Thesis','Choose where do you want to save');
end
%% Get path
path_data=fullfile(folder,[name,ext]);
%% LoadEEG
p_data=load(path_data);
p_data=p_data.p_global;
p_data=struct2cell(p_data)';
i_channel=[1:6];
feature=[1:12];
subject_id='Global';
subject_train=[1:size(p_data,1)];
feature_name={'Delta',...
                ;'Theta',...
                ;'Alpha',...
                ;'Beta',...
                ;'Gamma (30-70 Hz)',...
                ;'Beta_Theta',...
                ;'Alpha_Beta',...
                ;'Theta_Alpha',...
                ;'Alpha+Beta+Gamma',...
                ;'Theta_Beta',...
                ;'Beta_(Theta+Alpha)',...
                ;'Alpha_Gamma'};
%% Run build model
for j=1:length(i_channel)
    %% Prepare save name
    channel_name=['channel',num2str(i_channel(j))];
    %% Prepare feature
    data_feature=arrayfun(@(x) mean(p_data{x,i_channel(j)}),subject_train,'UniformOutput',false)';
    data=vertcat(data_feature{:});
    label={'Rest','Concentration'};
    value_label=[-1,0];
    p_gr=vertcat(p_data{subject_train,end});
    % Get label
    p_label=categorical(p_gr,value_label,label);
    % Create train and test set
    i_remove=find(p_gr==1);
    data(i_remove,:)=[];
    p_gr(i_remove,:)=[];
    p_label(i_remove,:)=[];
    % Data with best feature
    %% Plot data based feature
    %% Get random feature
    i_feature=nchoosek(feature,2);
    %% Prepare path for saving
    if ~exist('folder_save')
        folder_save=uigetdir;
    end
    subject_id=subfolders(i).name;
    disp(subject_id);
    disp('Remain');
    disp(length(subfolders)-i);
    path_save=fullfile(folder_save,subject_id);
    folder_save_channel=fullfile(path_save,channel_name);
    % Create folder to save
    mkdir (folder_save_channel)
    path_save_figure=[folder_save_channel,'\',subject_id];
        %% Plot
        for z=1:length(i_feature)
            %% Run without loop
            % Get feature
            i_concentration=find(p_gr==0);
            i_rest=find(p_gr==-1);
            feature_1=i_feature(z,1);
            feature_2=i_feature(z,2);
            m=length(data);
            % Plot 1D
            figure
            subplot(2,1,1)
%             gscatter([1:m],data(:,feature_1),p_gr)
            hold on
            plot(data(i_rest,feature_1))
            plot(data(i_concentration,feature_1))
            xlabel('Sample')
            ylabel(feature_name{feature_1});
            legend('Rest','Concentration','Location','northeast');
            hold off 
            axis([1 length(i_rest) 0 max(data(:,feature_1))])
            subplot(2,1,2)
            hold on
%             gscatter([1:m],data(:,feature_2),p_gr)
            plot(data(i_rest,feature_2))
            plot(data(i_concentration,feature_2))
            xlabel('Sample')
            ylabel(feature_name{feature_2});
            legend('Rest','Concentration','Location','northeast');
            axis([1 length(i_rest) 0 max(data(:,feature_2))])
            hold off
            %% Save
            name_save=[feature_name{feature_1}];
            set(gcf,'WindowState','maximized');
            saveas(gcf,[path_save_figure,'_',name_save,'.bitmap']);
            close all
            %% Plot 2D
            figure
            hold on
            gscatter(data(:,feature_1),data(:,feature_2),p_gr);
%             plot(data(i_rest,feature_1),data(i_rest,feature_2));
%             plot(data(i_concentration,feature_1),data(i_concentration,feature_2));

            xlabel(feature_name{feature_1})
            ylabel(feature_name{feature_2})
            legend('Rest','Concentration','Location','northeast');
            hold off
            axis([0 max(data(:,feature_1)) 0 max(data(:,feature_2))])

            %% Save
            name_save=[feature_name{feature_1},'_',feature_name{feature_2}];

            set(gcf,'WindowState','maximized');
            saveas(gcf,[path_save_figure,'_',name_save,'.bitmap']);
            close all
        end
    end