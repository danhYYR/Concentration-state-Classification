function data=Loaddata(path,range)
if nargin<2
    [filepath, name, ext] = fileparts(path);
    switch(ext)
        case'.mat'
        data=load(path);
        case".edf"
             [header,data]=edfread(path);
             data=data';
        otherwise
            data=readmatrix(path);
    end
else
    data=readmatrix(path,'Range',range);
end
end