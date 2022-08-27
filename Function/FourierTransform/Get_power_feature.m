function [P] = Get_power_feature(data,fs)
    [PSD,f]=fft_function(data,fs,"Power_Density");
    P=sum(PSD);
end

