function event = get_event_segments(event_file_path)
% GET_EVENT_SEGMENTS extracts segment data from an EEG data file based on an event file
%   event = get_event_segments(eeg_data, event_file_path) reads an EEG data file
%   containing raw EEG data and an event file containing the start and end times of each
%   event. The function extracts the segment data corresponding to each event and returns
%   the event information in a cell array.
%
%   Input arguments:
%   - eeg_data: a matrix containing the raw EEG data, where each row represents a channel
%   and each column represents a time point.
%   - event_file_path: a string containing the path of the event file. The event file
%   should contain two columns: the name of the event (including the event label and
%   duration in "hh:mm:ss" format separated by a tab character), and the start time of
%   the event in seconds from the beginning of the recording.
%
%   Output argument:
%   - event: a cell array containing the event information for each event, where each row
%   represents an event and the columns contain the label, start time, and duration of the
%   event, respectively.

% Read event file from row containing "Exam Start"
events = readcell(event_file_path, 'Delimiter', '\t');
i_row = find(strcmp(events(:,1), 'Exam Start'), 1);
% Extract segment data for each event and store event information
num_events = size(events, 1);
event = cell(num_events-i_row, 3);
for i = i_row:num_events-1
    % Get event label and duration
    event_label = events{i, 1};    
    % Get event start time
    start_time = events{i, 2};
    duration=events{i+1,2}-events{i,2};
    % Store event information in output variable
    event{i-i_row+1, 1} = event_label;
    event{i-i_row+1, 2} = start_time;
    event{i-i_row+1, 3} = duration;
end

end

function start_row = find_start_row(file_path)
% FIND_START_ROW finds the row in the event file that contains "Exam Start"
%   start_row = find_start_row(file_path) reads the event file located at file_path
%   and returns the row number containing the string "Exam Start".

% Open file
fid = fopen(file_path, 'r');

% Search for "Exam Start"
line_num = 1;
while ~feof(fid)
    line = fgetl(fid);
    if contains(line, 'Exam Start')
        start_row = line_num;
        fclose(fid);
        return
    end
    line_num = line_num + 1;
end

% "Exam Start" not found
error('Event file does not contain "Exam Start"');
end
