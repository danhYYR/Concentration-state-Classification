% These script to detecting the position of SEM appearance from PHYSIONET
% database
coff_mean_filt=0.25; %cofficient of mean filter
epoch_duration=10;
m=epoch_duration*fs;
n=2;
t=[1:m]/fs;
%Criteria for SEM recording
width_thres=0.5;
height_underthres=50;
height_upperthres=100;
time_SEM1=zeros(total_epoch,1);%Because of EOG in PHYSIONET database has only 1 channel
data=[EOG];%Because of EOG in PHYSIONET database has only 1 channel
for h=1:total_epoch %analyze in each epoch
    part=data(int64(fs)*(h-1)*epoch_duration+1:int64(fs)*h*epoch_duration);
    %Filter data 
    %50Hz noise
%     d = designfilt('bandstopiir','FilterOrder',2, ...
%                'HalfPowerFrequency1',49,'HalfPowerFrequency2',51, ...
%                'DesignMethod','butter','SampleRate',fs);
%     part = filtfilt(d,part);
    
    %Using Notch filter
    F0_notch = 50*2/fs; % Quy ve tan so chuan hoa
    %Design Notch filter
    d_notch = fdesign.notch('N,F0,Q',6,F0_notch,10,fs);
    Hd_notch = design(d_notch);
    %Appy all filter to EOG data
    part = filter(Hd_notch,part);
    
    %Baseline removal
    d = designfilt('highpassiir','StopbandFrequency',0.1 ,...
  'PassbandFrequency',0.25,'StopbandAttenuation',65, ...
  'PassbandRipple',0.1,'SampleRate',fs,'DesignMethod','butter');
    part = filtfilt(d,part);
    temp_EOG=part(:);

    %Smoothen data
    cc= 1:(coff_mean_filt*100):length(t);
    for j=1:length(cc)-1
    time(j,1)= cc(j);
    %time(j,2)= cc(j+1);    
    end

z=1;%Because of EOG in PHYSIONET database has only 1 channel
temp=[];
for k=1:size(time,1)
    temp=[temp median(temp_EOG(time(k,1),z))]; 
end
smooth=temp';
%Find minima and maxima
[ymax{z},tmax{z},ymin{z},tmin{z}] = extrema(smooth(:,z));

z=1;%Because of EOG in PHYSIONET database has only 1 channel
x=t(time(:));
    for j=1:length(tmin{z})-1
        t1=x(tmin{z}(j));
        if isempty(x(min(find(tmax{z}>tmin{z}(j)))))==0
            a=min(find(tmax{z}>tmin{z}(j)));
            t2=x(tmax{z}(a));
            width=t2-t1;
            height=ymax{z}(a)-ymin{z}(j);
            if width>width_thres && height>height_underthres  && height/width<400 && width/(x(tmin{z}(j+1))-x(tmin{z}(j)))<0.7 && ~isempty(find(t2==x(tmax{1})))==1 %&& max(EOG(:,z))<250 && abs(min(EOG(:,z)))<250
                time_SEM1(h,z)=time_SEM1(h,z)+x(tmin{z}(j+1))-x(tmin{z}(j));
            end
        end
        end
end

