function [Dsum] = wavelet_analyze(S,start,level,wavename)
[m,n]=size(S);
Dsum=zeros(m,n);
for i = 1:n
    [Cf(:,i),L(:,i)] = wavedec(S(:,i),level,wavename);
    for j=1:level
        Dn(:,(i-1)*level+j)=wrcoef('d',Cf(:,i),L(:,i),wavename,j);
    end
    for j=start:level
        Dsum(:,i)=Dsum(:,i)+Dn(:,(i-1)*level+j);
    end
end
