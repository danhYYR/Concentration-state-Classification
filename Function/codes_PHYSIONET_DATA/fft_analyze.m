function [Power_Density] = fft_analyze(S,fs)
n=length(S);
temp=fft(S,n);
%Amplitude = 2*abs(temp)/n;
%Power = ((abs(temp)).^2)/n;
Power_Density = ((abs(temp)).^2)/(n*fs);
