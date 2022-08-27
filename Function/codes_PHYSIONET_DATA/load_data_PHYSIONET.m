% The script file is reading data from PHYSIONET database - convert from EDF data)

[file_name,path_name] = uigetfile('*.csv','Select a csv file');
temp_data = readmatrix(strcat(path_name,file_name),'Range','D1');
time_vector = temp_data(:,1);
fs = double(1/(time_vector(2)-time_vector(1)));
FpzCz = temp_data(:,2);
PzOz = temp_data(:,3);
EOG = temp_data(:,4);
clear temp_data;
%save (strcat(folder_name,'\data.mat'));

[file_name,path_name] = uigetfile('*.csv','Select a csv file');
temp_data = readmatrix(strcat(path_name,file_name),'Range','D1');
time_vector_EMG = temp_data(:,1);
fs_EMG = double(1/(time_vector_EMG(2)-time_vector_EMG(1)));
EMG = temp_data(:,2);
clear temp_data;
%save (strcat(folder_name,'\data.mat'));