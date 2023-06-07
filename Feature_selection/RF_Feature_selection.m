close all;clc;clear all;
run('..\Function\load_function.m')
%% Run this to load file
path_file='..\Data_save\Result\Classification\Self-accquistion\Thesis';
[folder,name,ext]=Loadfile('.mat',path_file);
% Getpath sav
if ~exist('folder_save')
    folder_save=uigetdir('..\Data_save\Result\Classification\Self-accquistion\Thesis','Choose where do you want to save');
end
%% Get path
for z=1:size(name,2)
    path{z}=fullfile(folder{z},name{z});
    folder_save_model=strsplit(name{z},'_');
    window_name{z}=folder_save_model{1};



    %% 
    load(path{z});
    %% Plot
    % Prepare
    Metric_name=fieldnames(Feature_score);
    for i=1:length(Metric_name)-1
        Metrics=Metric_name{i};
        Ranking_channel=Feature_score.(Metrics);
        figure
        channel_num=[2,5];
        for j=1:length(channel_num)
            Ranking_feature=vertcat(Ranking_channel{:,channel_num(j)});
            %% Plot with mean and std
            subplot(length(channel_num),1,j)
            plot_performance_compare(Ranking_feature,Metrics);
            title(['Feature Score by ',Metrics,' on channel ',num2str(channel_num(j))])
            legend(['Channel ',num2str(channel_num(j))])
            grid on

        end
        %% Save cfs matrix
        set(gcf,'WindowState','maximized');
        path_save_figure=fullfile(folder_save,[window_name{z},'_',Metrics]);
        saveas(gcf,[path_save_figure,'.bmp']);
        close all
    end
end

function plot_performance_compare(arr,Group)
% models: a cell array of strings containing the names of the models
% accuracy: a vector of the accuracy scores for each model
% precision: a matrix of the precision scores for each model and class
% recall: a matrix of the recall scores for each model and class
    idx_nan=find(isnan(arr));
    arr(idx_nan)=0;
    bar_value=mean(arr);
    % std
    bar_err =std(arr);
    % Num feature
    num_arr=[1:size(arr,2)];
    % Plotting
    % Errorbar
    errorbar(num_arr,bar_value,bar_err)
    xlabel('Feature');
    ylabel('Feature Score');
    axis([0.8 max(num_arr)+0.2 min(bar_value-bar_err) max(bar_value+bar_err)])
end