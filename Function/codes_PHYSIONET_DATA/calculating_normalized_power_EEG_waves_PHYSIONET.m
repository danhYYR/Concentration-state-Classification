% Calculate Normalized Power of each channel
% Number of rows = number of epochs
% Column No.1: Delta Normalized
% Column No.2: Theta Normalized
% Column No.3: Alpha Normalized
% Column No.4: Beta Normalized
% Column No.5: Delta1 Normalized
% Column No.6: Delta2 Normalized
% Column No.7: Theta1 Normalized
% Column No.8: Theta2 Normalized
% Column No.9: Alpha1 Normalized
% Column No.10: Alpha2 Normalized
% Column No.11: Beta1 Normalized
% Column No.12: Beta2 Normalized
% Definition of each waves in below
% Delta = Delta1 + Delta2
% Theta = Theta1 + Theta2
% Alpha = Alpha1 + Alpha2
% Beta = Beta1 + Beta2
% Delta1 [0;1.9) Hz
% Delta2 [1.9;3.4) Hz
% Theta1 [3.4;5.4) Hz
% Theta2 [5.4;7.4) Hz
% Alpha1 [7.4;9.9) Hz
% Alpha2 [9.9;12.4) Hz
% Beta1  [12.4;17.9) Hz
% Beta2  [17.9;35) Hz
% The script file is Calculating the Normalized Power of various EEG waves
% from PHYSIONET database
epoch_duration = input('How many seconds of an epoch? Value = ');%value of an epoch
total_epoch = fix(length(time_vector)/(fs*epoch_duration));
t=[0:fs*epoch_duration-1]/fs;%create the vector of time domain for Amplitude diagram
f=(0:fs*epoch_duration-1)*(1/epoch_duration);%create the vector of frequency for FFT diagram

BorderValue=[0 1.9;1.9 3.4;3.4 5.4;5.4 7.4;7.4 9.9;9.9 12.4;12.4 17.9;17.9 35]; %declare border of various EEG waves

for a=1:size(BorderValue,1)
    q=1;
    temp=[];
    for j=1:size(f',1)
    if f(j)>=BorderValue(a,1) && f(j)<BorderValue(a,2)%chi lay can trai cua BorderValue
        temp(q,1)=j;
        q=q+1;
    end
    end
    BorderAddress(a,1)=min(temp);
    BorderAddress(a,2)=max(temp);
end

    Normalized_Power_wave_data=[];
    for i=1:total_epoch
    temp=FpzCz_FFT_Filtered(fix(fs*epoch_duration*(i-1)+1):fix(fs*epoch_duration*i));
    P=temp;
    Psum=zeros(1,8);
    for k=1:size(Psum,2)%i chay theo tung vung 
        for l=1:size(f',1)% j chay theo tung gia tri tan so
            if l>=BorderAddress(k,1) && l<=BorderAddress(k,2)
              Psum(k)=Psum(k)+P(l);
            end
        end
    end
    for m=1:size(Psum,2)
        N1=(Psum(1)+Psum(2))/sum(Psum); % Col No.1: Delta Normalized
        N2=(Psum(3)+Psum(4))/sum(Psum); % Col No.2: Theta Normalized
        N3=(Psum(5)+Psum(6))/sum(Psum); % Col No.3: Alpha Normalized
        N4=(Psum(7)+Psum(8))/sum(Psum); % Col No.4: Beta Normalized
        N5=Psum(1)/sum(Psum); % Col No.5: Delta1 Normalized
        N6=Psum(2)/sum(Psum); % Col No.6: Delta2 Normalized
        N7=Psum(3)/sum(Psum); % Col No.7: Theta1 Normalized
        N8=Psum(4)/sum(Psum); % Col No.8: Theta2 Normalized
        N9=Psum(5)/sum(Psum); % Col No.9: Alpha1 Normalized
        N10=Psum(6)/sum(Psum); % Col No.10: Alpha2 Normalized
        N11=Psum(7)/sum(Psum); % Col No.11: Beta1 Normalized
        N12=Psum(8)/sum(Psum); % Col No.12: Beta2 Normalized
    end
        Normalized_Power_wave_data=[Normalized_Power_wave_data;N1 N2 N3 N4 N5 N6 N7 N8 N9 N10 N11 N12];
    end 
    assignin('base','FpzCz_Normalized_Power_waves',Normalized_Power_wave_data);
    
    Normalized_Power_wave_data=[];
    for i=1:total_epoch
    temp=PzOz_FFT_Filtered(fix(fs*epoch_duration*(i-1)+1):fix(fs*epoch_duration*i));
    P=temp;
    Psum=zeros(1,8);
    for k=1:size(Psum,2)%i chay theo tung vung 
        for l=1:size(f',1)% j chay theo tung gia tri tan so
            if l>=BorderAddress(k,1) && l<=BorderAddress(k,2)
              Psum(k)=Psum(k)+P(l);
            end
        end
    end
    for m=1:size(Psum,2)
        N1=(Psum(1)+Psum(2))/sum(Psum); % Col No.1: Delta Normalized
        N2=(Psum(3)+Psum(4))/sum(Psum); % Col No.2: Theta Normalized
        N3=(Psum(5)+Psum(6))/sum(Psum); % Col No.3: Alpha Normalized
        N4=(Psum(7)+Psum(8))/sum(Psum); % Col No.4: Beta Normalized
        N5=Psum(1)/sum(Psum); % Col No.5: Delta1 Normalized
        N6=Psum(2)/sum(Psum); % Col No.6: Delta2 Normalized
        N7=Psum(3)/sum(Psum); % Col No.7: Theta1 Normalized
        N8=Psum(4)/sum(Psum); % Col No.8: Theta2 Normalized
        N9=Psum(5)/sum(Psum); % Col No.9: Alpha1 Normalized
        N10=Psum(6)/sum(Psum); % Col No.10: Alpha2 Normalized
        N11=Psum(7)/sum(Psum); % Col No.11: Beta1 Normalized
        N12=Psum(8)/sum(Psum); % Col No.12: Beta2 Normalized
    end
        Normalized_Power_wave_data=[Normalized_Power_wave_data;N1 N2 N3 N4 N5 N6 N7 N8 N9 N10 N11 N12];
    end 
    assignin('base','PzOz_Normalized_Power_waves',Normalized_Power_wave_data);
   
        