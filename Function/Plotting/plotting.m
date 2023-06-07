function ax=plotting(EEG,channel,option)
    font_name='Time New Roman';
    font_size=13;
    events=EEG.event;
    
    switch(option)
        case 'Annotation'
            figure;
            plot_annotations(EEG.data,events,channel);
            title('Signal after segment','FontName',font_name,'FontSize',font_size)
            xlabel('Time (s)','FontName',font_name,'FontSize',font_size)
            ylabel('Amplitude (\muV)','FontName',font_name,'FontSize',font_size)
            ax=gca;
        case 'Time'
            figure;
            subplot(1,2,1)
            plot_time(EEG.data,events,channel);
            title('Raw signal','FontName',font_name,'FontSize',font_size);
            grid on
            ax(1)=gca;
            subplot(1,2,2)
            plot_time(EEG.filtered,events,channel);
            title('Filtered Signal','FontName',font_name,'FontSize',font_size)
            grid on
            ax(2)=gca;
            
        case 'Frequency'
            figure
            subplot(1,2,1)
            plot_frequency(EEG.data,EEG.srate,channel);
            title('Raw Signal','FontName',font_name,'FontSize',font_size);
            grid on
            ax(1)=gca;

            subplot(1,2,2)
            plot_frequency(EEG.filtered,EEG.srate,channel);
            title('Filtered Signal','FontName',font_name,'FontSize',font_size)
            grid on
            ax(2)=gca;

        case 'Time and Frequency'
    end
end
function plot_annotations(data,event,channel)
    % EEG: EEG data struct based on eeglab
    % Add the event_cell to the EEG data as annotations
    % Create the annotation plot
    event_cell=event;

    plot(data(:,channel));
    % Set x-axis limit to 3 seconds
    xlim([0 30*500]);
    ylim([-300 300])
    grid on
    hold on
    ax = gca;
    %% Get color from event
    color_order={'green', 'blue', [1, 1, 0], 'red'};
    event_colors=generateEventColors(event_cell,color_order);
    line_type_order = {'-', '--', '-.'};
    event_line_types = generateEventLineTypes(event_cell, line_type_order);
    % Plot event_cell
    for i = 1:length(event_cell)
        onset = event_cell{i,2};
        duration =event_cell{i,3};
        label = event_cell{i,1};
        
        % Get the color for this event label
        if isKey(event_colors, label)
            color = event_colors(label);
            linetype=event_line_types(label);
        else
            color = 'k'; % black for unknown event labels
            linetype=':';
        end

        % Plot a vertical line at the event onset with the appropriate color
        x = onset + 1; % add 1 to convert from 0-index to 1-index
        yl = ylim; % get the y-limits of the plot
        line([x x], [yl(1) yl(2)], 'Color', color, 'LineWidth', 2,'LineStyle',linetype);

        % Add a label above the line with the event type
        text(x, yl(2), label, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Color', color);
    end

    axis([event_cell{2,2}-500 event_cell{3,2}+500 -400 400])

end
%% Generate based on event
function [event_colors] = generateEventColors(events, color_order)
% events: cell array of events containing label, onset, and duration
% color_order: a cell array of color names or RGB values in the desired order
% Example: color_order = {'green', 'blue', [1, 1, 0], 'red'}
    % Get unique event labels
    labels = unique(events(:, 1));

    % Map event labels to colors in the desired order
    num_colors = length(color_order);
    event_colors = containers.Map();
    for i = 1:length(labels)
        % Get the index of this label in the list of unique labels
        label_idx = find(strcmp(labels{i}, labels));

        % Map this label to the corresponding color in the order
        color_idx = mod(label_idx - 1, num_colors) + 1;
        event_colors(labels{i}) = color_order{color_idx};
    end
end
function [event_line_types] = generateEventLineTypes(events, line_type_order)
% events: cell array of events containing label, onset, and duration
% line_type_order: a cell array of line types in the desired order
% Example: line_type_order = {'-', '--', ':', '-.'}

    % Get unique event labels
    labels = unique(events(:, 1));

    % Map event labels to line types in the desired order
    num_line_types = length(line_type_order);
    event_line_types = containers.Map();
    for i = 1:length(labels)
        % Get the index of this label in the list of unique labels
        label_idx = find(strcmp(labels{i}, labels));

        % Map this label to the corresponding line type in the order
        line_type_idx = mod(label_idx - 1, num_line_types) + 1;
        event_line_types(labels{i}) = line_type_order{line_type_idx};
    end
end

%%Plot data following domain
function plot_frequency(data,fs,channel)
    %% Plot as FFT original
    [PSD,f]=fft_function(data(:,channel),fs,"Power_Density");
    L=length(data);
    i_fEEG=find(f>=0.5);
    plot(f(i_fEEG),PSD(i_fEEG))% Magic number 2
    xlabel('f (Hz)')
    ylabel('PSD (\muV^2/Hz)')
    axis([0.5 60 0 50])
end
function plot_time(data, event_cell, channel)
    %% Remove NAN
    [row col]=find(isnan(data));
    data(:,7:end)=[];
    %% Get event colors from event_cell
    color_order={'green', 'blue', [1, 1, 0], 'red'};
    event_colors=generateEventColors(event_cell,color_order);
    line_type_order = {'-', '--', '-.'};
    event_line_types = generateEventLineTypes(event_cell, line_type_order);
    %% ModifyEvent
    t=[1:length(data)];
    % Find outEvent
    % Generate the sub_event will include all of sample
    out_event_indices = true(1,length(t));
    % Set the Sample of main event = false
    for i=1:size(event_cell,1)
        onset = event_cell{i,2};
        duration = event_cell{i,3};
        out_event_indices(onset:onset+duration-1) = false;
    end
    % Get the outEvent
    out_event_indices = find(out_event_indices);
    % Modify the outEvent follow form: Type,Latency,Duration
    % Generate the suboutEvent
    tmp=[1,out_event_indices(1:end-1)];
    out_event_latency=out_event_indices-tmp;
    % Find Duration of Event by find the index have difference >1
    idx_out_event=find(out_event_latency~=1);
    if ~isempty(out_event_indices)
        for i=2:length(idx_out_event)-1
            onset = out_event_indices(idx_out_event(i-1));
            duration = out_event_indices(idx_out_event(i)-1)-onset;
            event_label = 'OutEvent';
            event_cell = [event_cell; {event_label, onset, duration}];
        end
    end
    %% Plot data for each event with color based on event label
    % Get the Num of event in file
    event_labels = unique(event_cell(:, 1),'stable');
    hold on;
    for i = 1:length(event_cell)
        onset = event_cell{i, 2};
        duration = event_cell{i, 3};
        label = event_cell{i, 1};

        % Get the color for this event label
        % Get the color for this event label
        if isKey(event_colors, label)
            color = event_colors(label);
            linetype=event_line_types(label);
        else
            color = 'k'; % black for unknown event labels
            linetype=':';
        end
            
        % Get data from onset to onset+duration
        t_range{i}=[onset:onset+duration-1];
        t_segment=[t_range{i}];

        data_segment = data(t_segment, channel);
        % Plot data with color based on event label
        idx_line=find(strcmp(event_labels,label));
        % Get the subplot
        h(idx_line)=plot(t_segment,data_segment,'Color', color);
    end
    % Add event legend
    legend(h,event_labels);
    xlabel('Time (s)')
    ylabel('Amplitude (\muV)');
    axis([t_range{1}(1) t_range{2}(end) -400 400])
end