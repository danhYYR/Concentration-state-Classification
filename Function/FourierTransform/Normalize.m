function [norm]=Normalize(x,fs)
   m=min(x);
   M=max(x);
   norm=(x-m)./(M-m);
end