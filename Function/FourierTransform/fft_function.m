function [FFT_Output,frequency] = fft_function(S,fs,option)
n=length(S);
temp=fft(S,n);
%S:source
%fs:frequency sampling
% Option is the output fft, "Amplitude","Power","Power_Density"
switch option
    case "Amplitude"
        FFT_Output = 2*abs(temp)/n;%Amplitude
    case "Power_Density"
        FFT_Output = ((abs(temp)).^2)/(n*fs);%Power_Density
    case "Power"
        FFT_Output = ((abs(temp)).^2)/n;%Power
    case "Power_Amplitude"
        FFT_Output = ((abs(temp)).^2)/(n*fs);%Power_Amplitude
end
frequency=(0:n-1)*(fs/n); %the frequency of fft

end