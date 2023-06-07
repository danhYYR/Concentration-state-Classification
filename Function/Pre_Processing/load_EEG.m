function EEG=load_EEG(eeg_data, event_cell, sample_rate,option)
    % eeg_data: EEG data matrix
    % event_cell: cell array of event_cell containing {label, start_time, duration}
    % sample_rate: sampling rate of the EEG data
    if ~exist('option','var')
        type='off';
    end
    EEG = struct();
    EEG.data = eeg_data;
    EEG.srate = sample_rate;
    EEG.nbchan = size(eeg_data, 1);
    EEG.pnts = size(eeg_data, 2);
    EEG.times = (0:EEG.pnts-1)/EEG.srate;
    % Convert the event cell to an EEGlab event struct
    for i = 1:size(event_cell,1)
        EEG.event(i).type = event_cell{i,1};
        EEG.event(i).latency = event_cell{i,2};
        EEG.event(i).duration = event_cell{i,3};
    end
    path_modifyevent='E:\Study\Thesis\Attention\Pre_processing\Get_label.m';
    run(path_modifyevent);
    if strcmp(option,'on')
        plot_annotations(EEG);
    end
end
