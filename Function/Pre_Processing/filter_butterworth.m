function filtered=filter_butterworth(data,fs,channel_get ,band_range)
%% SECTION TITLE
%% 
% Certainly! Here's a brief introduction to the function filter_butterworth:
%
% Objective:
% The filter_butterworth function is designed to filter EEG (electroencephalography) data using a Butterworth filter. The function takes in raw EEG data and a specified frequency range, and returns a filtered EEG signal that has been processed using a series of filtering techniques.
%
% Input:
%
% EEG: A structure containing raw EEG data, including the data itself, sampling rate, and event information.
% band_range: A two-element vector specifying the frequency range to filter the EEG signal, in Hz.
% Output:
%
% filtered: The filtered EEG signal after applying a notch filter, bandpass filter, wavelet transform, and EOG (electrooculography) artifact removal by MIT method by Quoc Tuong Minh.
%% 
    data(~isfinite(data)) = 0;
    % Get the data max of the trial data with EEG.event{end,2}+EEG.event{end,3}
    trial_data = data(1:length(data),:);    
    % Design notch filter with filtfilt function
    wo = 50/(fs/2);
    bw = wo/35;
    [b_notch, a_notch] = iirnotch(wo, bw);
    
    % Manual select filter level
    filt_order = 4;
    
    % Design bandpass filter following Butterworth
    f_low = band_range(1);
    f_high = band_range(2);
    [b_bandpass, a_bandpass] = butter(filt_order, [f_low, f_high]/(fs/2), 'bandpass');
    
    %% Filter data
    % Notch
    filtered_nothch = filtfilt(b_notch, a_notch, trial_data);
    % Bandpass
    filtered_bandpass = filtfilt(b_bandpass, a_bandpass, filtered_nothch);
    % Wavelet
    filtered_wavelet=get_waveletdata(filtered_bandpass,fs,[f_low f_high],'db8');% sym9, db7, coif3 is suitable for eeg
    % EOG removal
    [filtered EOG_estimate]=MTfilt(filtered_wavelet,fs,0.97);
    % Scale the filtered data to the same range as the original data
end
