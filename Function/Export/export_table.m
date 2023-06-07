function [table_edited]=export_table(path,option)
    table_input=readtable(path);
    switch(option)
        case 'Highlight'
           table_edited=highlight_table_max(table_input);
    end
end
function highlight_table = highlight_table_max(table_input)
    % Get table data and variable names
    table_data = table2array(table_input(:,2:end-2));

    % Find max value in each column
    [~, max_idx] = max(table_data, [], 1);

    % Initialize cell array to store highlight data
    highlight_data = repmat({''}, size(table_data));

    % Highlight max value in each column
    for i = 1:size(table_data,2)
        highlight_data(max_idx(i), i) = {'background-color: #FFFF00'};
    end

    % Convert highlight data to string array and assign to 'style' property
    table_input(:,2:end-2).Style = highlight_data;

    % Return modified table
    highlight_table = table_input;
end


