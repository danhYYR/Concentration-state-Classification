function [file_path,file_name,file_ext]=Loadfile(type,path_load)
if ~exist('type','var')
    type='*';
end
if ~exist('path_load','var')
    path_load=['.'];
end
    path_load=[path_load,'\',type];
    [file_name, folder] = uigetfile(path_load, 'MultiSelect', 'on');
    if iscell(file_name)
        for i=1:length(file_name)
            path=[folder,file_name{i}];
            [path, name, ext] = fileparts(path);
            file_path{i}=path;
            file_name{i}=name;
            file_ext{i}=ext;
        end
    else
        path = [folder,file_name];
        [file_path, file_name, file_ext] = fileparts(path);
    end
end