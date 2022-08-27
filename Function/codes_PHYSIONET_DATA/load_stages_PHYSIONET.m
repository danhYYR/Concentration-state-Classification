% The script file is reading stages from PHYSIONET database and convert
% these stages to number value

[file_name_stage,path_name] = uigetfile('*.csv','Select a file');
temp_data = readtable(strcat(path_name,file_name_stage),'PreserveVariableNames',true);
temp_data_1=table2array(temp_data(:,3));
temp_data_2=table2array(temp_data(:,4));
temp_data_3=cell2mat(table2array(temp_data(:,5)));
temp_data_4=(1:length(temp_data_3))';
for i=1:length(temp_data_4)
    if temp_data_3(i,:)=  == 'Sleep stage W'
        temp_data_4(i) = 0; % Wake Stage
    elseif temp_data_3(i,:) == 'Sleep stage 1'
        temp_data_4(i) = 1; % Stage N1
    elseif temp_data_3(i,:) == 'Sleep stage 2'
        temp_data_4(i) = 2; % Stage N2
    elseif temp_data_3(i,:) == 'Sleep stage 3'
        temp_data_4(i) = 3; % Stage N3
    elseif temp_data_3(i,:) == 'Sleep stage 4'
        temp_data_4(i) = 3; % Stage N3
    elseif temp_data_3(i,:) == 'Sleep stage R'
        temp_data_4(i) = 4; % Stage REM
    else
        temp_data_4(i) = 0; % Wake Stage
    end
end
STAGE=(zeros(1,temp_data_1(end)))';
for i=1:size(temp_data_1)
    STAGE((temp_data_1(i)+1):(temp_data_1(i)+temp_data_2(i)+2))= temp_data_4(i);
end
clear temp_data temp_data_1 temp_data_2 temp_data_3 temp_data_4 i ans