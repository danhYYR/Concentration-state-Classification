flag_true_delta_1=find(flag_Delta_in_channel_FpzCz==1);
flag_true_delta_2=find(flag_Delta_in_channel_PzOz==1);
flag_true_delta_1=flag_true_delta_1';
flag_true_delta_2=flag_true_delta_2';
flag_true_delta_A=zeros(1,total_epoch);
for i=1:length(flag_true_delta_1)
	flag_true_delta_A(flag_true_delta_1(i))=1;
end
flag_true_delta_B=zeros(1,total_epoch);
for i=1:length(flag_true_delta_2)
	flag_true_delta_B(flag_true_delta_2(i))=1;
end
flag_true_delta=flag_true_delta_A & flag_true_delta_B;
flag_true_delta=find(flag_true_delta'==1);

true_delta_data=[];
for i=1:length(flag_true_delta)
temp=PzOz_Ratio_Power_waves(flag_true_delta(i),1);
true_delta_data=[true_delta_data;temp];
end

flag_false_delta_1=find(flag_Delta_in_channel_FpzCz==0);
flag_false_delta_2=find(flag_Delta_in_channel_PzOz==0);
flag_false_delta_1=flag_false_delta_1';
flag_false_delta_2=flag_false_delta_2';
flag_false_delta_A=ones(1,total_epoch);
for i=1:length(flag_false_delta_1)
	flag_false_delta_A(flag_false_delta_1(i))=0;
end
flag_false_delta_B=ones(1,total_epoch);
for i=1:length(flag_false_delta_2)
	flag_false_delta_B(flag_false_delta_2(i))=0;
end
flag_false_delta=flag_false_delta_A|flag_false_delta_B;
flag_false_delta=find(flag_false_delta==0);

false_delta_data=[];
for i=1:length(flag_false_delta)
temp=PzOz_Ratio_Power_waves(flag_false_delta(i),1);
false_delta_data=[false_delta_data;temp];
end

total_delta_data=[true_delta_data;false_delta_data];
total_delta_labels=[ones(length(flag_true_delta),1);zeros(length(flag_false_delta),1)];

flag_Delta_in_PzOz_channels=SVM_function(total_delta_data(:),ones(1,length(total_delta_data)),total_delta_labels(:),PzOz_Ratio_Power_waves(:,1),ones(1,length(PzOz_Ratio_Power_waves)));
flag_Delta_in_FpzCz_channels=SVM_function(total_delta_data(:),ones(1,length(total_delta_data)),total_delta_labels(:),FpzCz_Ratio_Power_waves(:,1),ones(1,length(FpzCz_Ratio_Power_waves)));
flag_Delta_in_total_channels=zeros(1,total_epoch);
for i=1:total_epoch
    if ((flag_Delta_in_PzOz_channels(i)==1)|(flag_Delta_in_FpzCz_channels(i)==1))==1
        flag_Delta_in_total_channels(i)=1;
    else
        flag_Delta_in_total_channels(i)=0;
    end
end

%labels=SVM_function_using_one_class(true_delta_data(:),ones(1,length(true_delta_data)),ones(1,length(true_delta_data)));
%SVM_function_using_one_class(ones(1,length(true_delta_data)),true_delta_data(:),ones(1,length(true_delta_data)));