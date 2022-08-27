% This script file to detect the CREM
CREM=[];
all_total_CREM=[];
for i=1:total_epoch
temp1=EOG(int64(fs)*epoch_duration*(i-1)+1:int64(fs)*epoch_duration*i);

d = fdesign.bandpass('n,f3dB1,f3dB2', 4, 1, 5, fs);
Hd=design(d,'butter');
temp1_filtered=filter(Hd,temp1);

C1_filtered=[];
for j=1:fs*epoch_duration
    temp_filtered=temp1_filtered(j).^2;
    C1_filtered=[C1_filtered temp_filtered];
end

temp_flag_CREM=0;
total_CREM=[];
for j=1:length(C1_filtered)
    if C1_filtered(j)>10
        if max(max(abs(temp1_filtered(j))))>100
        C1_filtered(j)=0;
        end
        C1_filtered(j)=C1_filtered(j);
    else
        C1_filtered(j)=0;
    end
    if C1_filtered(j)>0
        temp_flag_CREM = temp_flag_CREM + 1;
    else
        if temp_flag_CREM >= 0.2*fs % >0.2s
            position = find(C1_filtered==max(C1_filtered(j-temp_flag_CREM:j)));
            if (position > 0.1*fs) && (position < epoch_duration*fs-0.1*fs)
                total_CREM = [j temp_flag_CREM position i;total_CREM];
            end
        end
        temp_flag_CREM = 0;
        position = 0;
    end
end


C2_filtered=C1_filtered;
for j=1:length(C2_filtered)
    if C2_filtered(j)>3000
        C2_filtered(j)=1;
    else
        C2_filtered(j)=0;
    end
end

sum_temp=sum(C2_filtered(1,:));
CREM=[CREM sum_temp];     
all_total_CREM = [all_total_CREM;total_CREM];
end
