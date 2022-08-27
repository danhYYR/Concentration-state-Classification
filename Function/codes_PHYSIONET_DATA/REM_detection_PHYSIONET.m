%This script detect exactly REM appear
REM_count=0;
all_total_REM_epoch=[];
for i=1:total_epoch
    epoch_position=find(all_total_CREM(:,4)==i);
    for j=min(epoch_position):max(epoch_position)
        if all_total_CREM(j,6)==1
            REM_count=REM_count+1;
        else
            REM_count=REM_count;
        end
    end
    all_total_REM_epoch=[all_total_REM_epoch;REM_count];
    REM_count=0;
end
% plot(all_total_REM_epoch)
% ylim([-1 max(all_total_REM_epoch)+1]);
