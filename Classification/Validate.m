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
i_channel=[2 5];
feature=[4];
subject_id='Global';
subject_train=[size(p_data,1)-2:size(p_data,1)];
%% Load model
% Get path
path_file='..\Data_save\Result\Classification\Self-accquistion\Thesis\K-Fold\Full_window\Global';
path_folder=uigetdir(path_file,'Choose Model to autoload');
% Get a list of all subfolders in the root folder
subfolders = dir(path_folder);
subfolders = subfolders([subfolders(:).isdir] & ~ismember({subfolders(:).name}, {'.', '..'}));

%% Loop over each subfolder and process its files
for i=1:size(subfolders,1)
%%
% i_error=8;
% for i = i_error:i_error
    subfolder = subfolders(i);
    subfolderPath = fullfile(path_folder, subfolder.name);
    % Get name_subject file
    % Get a list of all files in the subfolder
    files = dir(fullfile(subfolderPath, '*.mat'));
    for j=1:size(files,1)
        filename=files(j).name;
        name_split=strsplit(filename,'_');
        Model_name{j}=name_split{6};
    end
%% Run Pre-built model

    Model_RF=loadCompactModel(fullfile(files(1).folder,files(1).name));
    Model_SVM=loadCompactModel(fullfile(files(2).folder,files(2).name));
%% Prepare save name
    
    channel_name=['channel',num2str(i)];

%     path_save=fullfile(folder_save,subject_id);
%     folder_save_channel=fullfile(path_save,channel_name);
%     % Create folder to save
%     path_save_figure=[folder_save_channel,'\',channel_name];
%     name_save=[channel_name];
%% Run build model
for j=1:length(i_channel)
    %% Prepare save name
    channel_name=['channel',num2str(i_channel(j))];
%     path_save=fullfile(folder_save,subject_id);
%     % Create folder to save
%     path_save_figure=[path_save,'\'];
%     name_save=['Channel_2_5_Feature_',num2str(feature)];
    %% Prepare feature
    data=vertcat(p_data{subject_train,i_channel(j)});
    label={'Rest','Concentration'};
    value_label=[-1,0];
    p_gr=vertcat(p_data{subject_train,end});
    data(:,end+1)=p_gr;
    % Get label
    p_label=categorical(data(:,end),value_label,label);
    % Create train and test set
    i_remove=find(data(:,end)==1);
    data(i_remove,:)=[];
    p_gr(i_remove,:)=[];
    p_label(i_remove,:)=[];
    % Data with best feature
    data_feature(:,j)=data(:,feature);

end

    x_test=data_feature;
    %% Test
    if exist('Model_SVM','var')&& exist('Model_RF','var')
        predict_model{1,i}=predict(Model_RF,x_test);
        predict_model{2,i}=predict(Model_SVM,x_test);
    else
        predict_model=predict(Model,x_test(:,feature));
    end
end
 %% Confusion matrix chart
y_actual=p_label;
for i=1:size(predict_model,1)
    figure
    predict_label=categorical(predict_model{i},value_label,label);
    predict_label(find(isundefined(predict_label)))=[];
    cm{i}=confusionmat(y_actual,predict_label);
    confusionchart(y_actual,predict_label);
    title(['Confusion matrix with Validate ',Model_name{i}])
end

        %% Caculate Accuracy,Recall,F1 score

i=1;
    % Model RF
    accuracy_1(i)= trace(cm{i})/sum(cm{i},'all')*100;
    precision_1(i)= cm{i}(4)/(cm{i}(3)+cm{i}(4))*100;
    recall_1(i)=cm{i}(4)/(cm{i}(2)+cm{i}(4))*100;
    F1_1(i)=2*precision_1(i)* recall_1(i)/( precision_1(i)+recall_1(i));
    % Model SVM
    accuracy_2(i)= trace(cm{i+1})/sum(cm{i+1},'all')*100;
    precision_2(i)= cm{i+1}(4)/(cm{i+1}(3)+cm{i+1}(4))*100;
    recall_2(i)=cm{i+1}(4)/(cm{i+1}(2)+cm{i+1}(4))*100;
    F1_2(i)=2*precision_2(i)* recall_2(i)/( precision_2(i)+recall_2(i));
    cfs_statical_1.(channel_name)=[accuracy_1',precision_1',recall_1',F1_1'];
    cfs_statical_2.(channel_name)=[accuracy_2',precision_2',recall_2',F1_2'];