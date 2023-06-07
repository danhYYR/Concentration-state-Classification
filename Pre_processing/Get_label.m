
%% Get data
fs=EEG.srate;
%%
label=get_labels(EEG);
EEG.event=label;
%% Function get label
function labels = get_labels(EEG)
%GET_LABELS extracts labels and their duration_stimulis from event data
%   event_raw: a struct with fields 'type', 'onset', and 'duration_stimuli'
%   labels: a cell array with three columns, type, latency, and duration_stimuli
    
    event_raw=EEG.event;
    data=EEG.data;
    max_sample=length(data);
    fs=EEG.srate;
    % find indices of 'Patient Event' events
    idx_concentration_high = find(strcmp({event_raw.type}, 'Patient Event'));
    
    % Generate sub_concentration_high for each 3 consecutive elements in idx_concentration_high
    sub_concentration_high = arrayfun(@(i) idx_concentration_high(i:i+2), 1:3:numel(idx_concentration_high)-2, 'UniformOutput', false);
    
    % Calculate duration_stimuli of Concentration High events using sub_concentration_high
    duration_concentration_high = cellfun(@(x) event_raw(x(2)).latency - event_raw(x(1)).latency, sub_concentration_high);

% find indices of 's' events
idx_event_s = find(strcmp({event_raw.type}, 's'));
if isempty(idx_event_s)
    idx_event_s = find(strcmp({event_raw.type}, 'start'));
    event_raw(idx_event_s(1)).latency=event_raw(idx_event_s(1)).latency+duration('00:03:20');
end
% Calculate duration_stimuli of concentration and rest events from s events
for i = 1:length(idx_event_s)
    % Edit "s" event duration to 5 minutes
    event_s = event_raw(idx_event_s(i)).latency;
    % Dont change duration time if you use our experiment
    session=5;
    duration_concentration=duration("00:00:30");
    duration_rest=duration("00:00:30");
    duration_state=duration("00:05:00");
    duration_break=duration("00:00:05");
    duration_miss=duration("00:00:01");
    duration_delay=duration("00:00:03");
    % Dont change below
    t_min_index=seconds(event_s)*fs-seconds(duration_miss)*fs;
    t_max_index=seconds(event_s-duration_miss+duration_state+duration_break*(session-1)+duration_delay*session)*fs;
    time_range_state=[t_min_index,t_max_index];
    time_concentration=seconds(duration_concentration)*fs;
    time_rest=seconds(duration_rest)*fs;
    time_break=seconds(duration_break)*fs;
    time_delay=seconds(duration_delay)*fs;
    if max_sample<time_range_state(1,2)
        event_fix=length(data)/fs-seconds(duration_state+duration_break*(session-1)+duration_delay*session);
        event_fix=[floor(event_fix/60),event_fix-floor(event_fix/60)*60];
        event_s=duration(0,event_fix(1,1),event_fix(1,2));
        t_min_index=seconds(event_s)*fs;
        t_max_index=seconds(event_s+duration_state+duration_break*(session-1)+duration_delay*session)*fs;
        time_range_state=[t_min_index,t_max_index];
    end
    % Get concentration and rest
    i_concentration=[time_range_state(1,1):time_concentration+time_rest+time_break+time_delay:time_range_state(1,2)];
    if length(i_concentration)>5
        i_concentration(end)=[];
    end
    i_rest=i_concentration+time_concentration+time_delay;
    sub_event_s=[i_concentration,i_rest]';
end
% Store concentration and rest events in labels cell array
        for i = 1:10
            if (i>5)
                labels{i, 1} = 'Rest';
            else
                labels{i, 1} = 'Concentration';
            end
            labels{i, 2} = sub_event_s(i);
            labels{i, 3} = time_concentration;
        end    
    % append concentration_high labels to labels cell array
    count = length(labels) + 1;
    for i = 1:length(sub_concentration_high)
        labels{count,1} = 'Concentration High';
        labels{count,2} = seconds(event_raw(sub_concentration_high{i}(1)).latency)*fs;
        labels{count,3} = seconds(duration_concentration_high(i))*fs;
        count = count + 1;
    end
        % sort labels with respect to latency
    [~, idx] = sort(cell2mat(labels(:,2)));
    labels = labels(idx,:);
end


