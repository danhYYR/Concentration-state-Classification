%This script help to detect the microwaves from PHYSIONET database
Channel_Name = input('Enter the Channel name that you want to detect micro waves = ');
Wavelet_Filtered_Name=strcat(Channel_Name,'_Wavelet_Filtered');
temp_Wavelet_Filtered_Name=eval(Wavelet_Filtered_Name);
flag_microwaves_Name=strcat('flag_Microwaves_in_channel_',Channel_Name);
flag_Microwaves = [];
num_of_K=1;

for num_of_epoch=1:total_epoch
    temp_Wavelet_Filtered_data=eval(Wavelet_Filtered_Name);%access to data of Wavlet analyzed signal
    epoch=(temp_Wavelet_Filtered_data(int64(fs)*epoch_duration*(num_of_epoch-1)+1:int64(fs)*epoch_duration*num_of_epoch))';
    temp=epoch;
    for i=4:length(epoch)-4
        if (temp(1,i-3)>=temp(1,i) && temp(1,i-2)>=temp(1,i) && temp(1,i-1)>=temp(1,i) && (temp(1,i))<=temp(1,i+1) && temp(1,i)<=temp(1,i+2)&& temp(1,i)<=temp(1,i+3))
            val_min=temp(1,i);
            t_min=i;       
        if i+fs+1<length(epoch)
            scan_max=temp(1,i+1:i+int64(fs)+1);
            val_max=max(scan_max);
        for l=i+1:i+fs+1
            if val_max==temp(1,l)
                t_max=l;
                break
            end
        end
      
 
        % Xac dinh t_end
        for m=t_max:length(epoch)
            if temp(1,m)<=-5
               t_end=m;
               break
            end
        end
       % Xac dinh t_start
        for n=t_min:-1:1
            if val_min/2<=temp(1,n)<=0 
            t_start=n;
            elseif temp(1,n)>0
                t_start=n;
                break
            end
        end
    
        % Xac dinh t_mid1
        for o=t_min:1:t_max
        if temp(1,o)>0
            t_mid1=o;
            break
        end
        end
        % Xac dinh t_mid2
        for p=t_max-1:-1:t_min
            if temp(1,p)<-5
                t_mid2=p;
                break
            else
                t_mid2=t_max;
            end
        end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Xac dinh 14 dac diem qua 8 thong so o tren
    %%%%
    f2=(t_mid2-t_mid1)/(t_end-t_start);
    f3=t_end-t_start;
    f4=(val_max-val_min);
    f8=abs(val_min)/val_max;
    f9=(t_end-t_mid1)/(t_mid1-t_start);
    f10=abs(val_min)/((t_mid1-t_start));
    f12=(val_max-val_min)/((t_end-t_start));    
    % Thong ke K-complexes xuat hien
    if (  f2<0 && 100<=f3 && f3<=300  && (f4>=100) && (f8>0.5) && f9>1 && f10>1 && f12>1 ) 
                
                
                if t_start-500>1
                    local_max_pre=max(epoch(1,t_start-500:t_start-200));
                    local_min_pre=min(epoch(1,t_start-500:t_start-200));
                else
                    local_max_pre=0;
                    local_min_pre=0;
                end
                
                if t_end+500<(30*fs)
                    local_max_after=max(epoch(1,t_end:t_end+500));
                    local_min_after=min(epoch(1,t_end:t_end+500));
                else
                    local_max_after=0;
                    local_min_after=0;
                end
                
       if local_max_pre<epoch(1,t_max) && local_min_pre>epoch(1,t_min ) && local_max_after<epoch(1,t_max) && local_min_after>epoch(1,t_min ) 
            gia_tri_K_complex{1,num_of_K}=[num_of_epoch;t_start;t_end];
            num_of_K=num_of_K+1;       
                
       end    
   end
   end
end
end
end
temp2=zeros(total_epoch,1);
for i=1:total_epoch
    for j=1:size(gia_tri_K_complex,2)
        temp3 = gia_tri_K_complex{j};
        if  temp3(1) == i
            temp2(i) =1;
        end
    end
end
assignin('base',flag_microwaves_Name,temp2);