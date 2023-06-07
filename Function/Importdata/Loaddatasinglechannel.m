%% Load data function will load data from cdt based on loadcurry with single channel
% This function use the I/O to read file following the channel
% The input including:
    % filename is the file path
    % channel is the interested channel
    % numchannel is the number of channel in file
    % numsample is the num of sample for one channel
    % ** Note ** :The data in this function is layout data following row (that mean 1 channel is 1 row)
% The ouput is data get from file    
% ** Note **: Because this function read data single channel with buffer 4
% byte, so if you want to optimize speed load All channel will using faster
function [data]=Loaddatasinglechannel(filename,channel,numchannel,numsample)

    [folder,file,ext] = fileparts(filename);
    data=nan*ones(length(channel),numsample);
    switch ext
        case ".cdt"
            % Open file in I/O level
            fid=fopen(filename,'r');
            if length(channel)<numchannel
                for i=1:length(channel)
                    % Move the pointer to the load data
                    % 4 is the bit of float type
                    fseek(fid,4*(channel(i)),'bof');
                    data(i,:)=fread(fid,[1 numsample],'float32',4*(numchannel-1));
                end
            else
               data=fread(fid,[numchannel numsample],'float32'); 
            end
                fclose(fid);
            data=data';
        case ".edf"
        otherwise
    end
end