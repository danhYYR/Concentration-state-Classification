function eeg = emotiv_filter(data_raw,t_range,option)
%% Syntax document    
    % data is the data have only EEG data from emotiv
    % t_range is the array with t_start index and t_end index
    %% Get Input
    t_start=min(t_range)+1;
    t_end=max(t_range);
    switch(option)
        case 'Raw'
            med = median(data_raw,2); % calculate median of each sample
            eeg_raw = data_raw - repmat(med, 1, size(data_raw,2)); % remove it
            %
            % limit slew rate
            for j=t_start:t_end 
                del = eeg_raw(j,:) - eeg_raw(j-1,:);
                del = min(del, ones(1,size(data_raw,2))*15);
                del = max(del, -ones(1,size(data_raw,2))*15);
                eeg(j,:) = eeg_raw(j-1,:) + del;
            end
        case 'FIR'
            %Get raw data
            eeg_raw=emotiv_filter(data_raw,t_range,'Raw');
            %% FIR filter
            % High pass filter
            a = 0.06; % HPF filter coeffs
            b = 0.94;
            preVal = zeros(1,size(data_raw,2));
            eeg = zeros(size(eeg_raw));
            for j=t_start:t_end
                preVal = a * eeg_raw(j,:) + b * preVal;
                eeg(j,:) = eeg_raw(j,:) - preVal;
            end
        case 'IIR'
            %% IIR filter
            IIR_TC = 256;                       % 2 second time constant- adjust as required
            EEG_data = data_raw( : ,size(data_raw,2));    % import raw data
            [rows, columns] = size(EEG_data);    % rows = number of data samples, columns = size(data_raw,2)
            back = EEG_data( 1, : );            % copy first row into background
            % run IIR filter
            for r = t_start:t_end
            back = (back * ( IIR_TC- 1 ) + EEG_data( r,:)) / IIR_TC;
            eeg = EEG_data( r,:) - back;
            end    
    end
end