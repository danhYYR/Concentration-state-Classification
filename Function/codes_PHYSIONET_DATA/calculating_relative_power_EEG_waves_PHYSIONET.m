% Calculate Relative power of each channel
% Number of rows = number of epochs
% Column No.1: Delta / Theta ***
% Column No.2: Delta / Alpha ***
% Column No.3: Delta / Beta ***
% Column No.4: Theta / Alpha
% Column No.5: Theta / Beta
% Column No.6: Alpha / Beta
% Column No.7: Delta1 / Delta2
% Column No.8: Theta1 / Theta2
% Column No.9: Alpha1 / Alpha2
% Column No.10: Beta1 / Beta2 ***
% Column No.11: Beta1 / Alpha
% Column No.12: Beta2 / Alpha
% Column No.13: (Delta + Theta) / (Alpha + Beta) ***
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
% The script file is Calculating the Relative Power of various EEG waves
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

    Relative_Power_wave_data=[];
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
        R1=(Psum(1)+Psum(2))/(Psum(3)+Psum(4)); % Col No.1: Delta / Theta
        R2=(Psum(1)+Psum(2))/(Psum(5)+Psum(6)); % Col No.2: Delta / Alpha
        R3=(Psum(1)+Psum(2))/(Psum(7)+Psum(8)); % Col No.3: Delta / Beta
        R4=(Psum(3)+Psum(4))/(Psum(5)+Psum(6)); % Col No.4: Theta / Alpha
        R5=(Psum(3)+Psum(4))/(Psum(7)+Psum(8)); % Col No.5: Theta / Beta
        R6=(Psum(5)+Psum(6))/(Psum(7)+Psum(8)); % Col No.6: Alpha / Beta
        R7=Psum(1)/Psum(2); % Col No.7: Delta1 / Delta2
        R8=Psum(3)/Psum(4); % Col No.8: Theta1 / Theta2
        R9=Psum(5)/Psum(6); % Col No.9: Alpha1 / Alpha2
        R10=Psum(7)/Psum(8); % Col No.10: Beta1 / Beta2
        R11=Psum(7)/(Psum(5)+Psum(6)); % Col No.11: Beta1 / Alpha
        R12=Psum(8)/(Psum(5)+Psum(6)); % Col No.12: Beta2 / Alpha
        R13=(Psum(1)+Psum(2)+Psum(3)+Psum(4))/((Psum(5)+Psum(6)+Psum(7)+Psum(8))); % Col No.13: (Delta + Theta) / (Alpha + Beta)
    end
        Relative_Power_wave_data=[Relative_Power_wave_data;R1 R2 R3 R4 R5 R6 R7 R8 R9 R10 R11 R12 R13];
    end 
    assignin('base','FpzCz_Relative_Power_waves',Relative_Power_wave_data);
    
    Relative_Power_wave_data=[];
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
        R1=(Psum(1)+Psum(2))/(Psum(3)+Psum(4)); % Col No.1: Delta / Theta
        R2=(Psum(1)+Psum(2))/(Psum(5)+Psum(6)); % Col No.2: Delta / Alpha
        R3=(Psum(1)+Psum(2))/(Psum(7)+Psum(8)); % Col No.3: Delta / Beta
        R4=(Psum(3)+Psum(4))/(Psum(5)+Psum(6)); % Col No.4: Theta / Alpha
        R5=(Psum(3)+Psum(4))/(Psum(7)+Psum(8)); % Col No.5: Theta / Beta
        R6=(Psum(5)+Psum(6))/(Psum(7)+Psum(8)); % Col No.6: Alpha / Beta
        R7=Psum(1)/Psum(2); % Col No.7: Delta1 / Delta2
        R8=Psum(3)/Psum(4); % Col No.8: Theta1 / Theta2
        R9=Psum(5)/Psum(6); % Col No.9: Alpha1 / Alpha2
        R10=Psum(7)/Psum(8); % Col No.10: Beta1 / Beta2
        R11=Psum(7)/(Psum(5)+Psum(6)); % Col No.11: Beta1 / Alpha
        R12=Psum(8)/(Psum(5)+Psum(6)); % Col No.12: Beta2 / Alpha
        R13=(Psum(1)+Psum(2)+Psum(3)+Psum(4))/((Psum(5)+Psum(6)+Psum(7)+Psum(8))); % Col No.13: (Delta + Theta) / (Alpha + Beta)
    end
        Relative_Power_wave_data=[Relative_Power_wave_data;R1 R2 R3 R4 R5 R6 R7 R8 R9 R10 R11 R12 R13];
    end 
    assignin('base','PzOz_Relative_Power_waves',Relative_Power_wave_data);
    
        