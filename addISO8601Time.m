function dataTable = addISO8601Time(dataTable)
    % ADDISO8601TIME Adds a column with ISO 8601 datetime objects to a table.
    %
    % This function takes a table as input, which must contain the following
    % columns: 'year', 'month', 'day', 'hour', 'minute', 'second'. It adds
    % a new column named 'origin_time' with datetime objects formatted
    % according to the ISO 8601 standard (e.g., 2020-12-31T23:59:59.123456).
    %
    % Input:
    %   dataTable - A table containing at least the required columns.
    %
    % Output:
    %   dataTable - The input table with an additional 'origin_time' column.
    %
    % Example:
    %   dataTable = addISO8601Time(dataTable);
    % The table should include columns: year, month, day, hour, minute, second.
    
    % Define possible column names for each component
    columnVariants = struct(...
        'year', {{'year', 'Year', 'YR', 'yr', 'Yr'}}, ...
        'month', {{'month', 'Month', 'MO', 'Mo', 'mo', 'mth', 'Mth', 'MTH'}}, ...
        'day', {{'day', 'Day', 'Da', 'da', 'DY', 'Dy', 'dy'}}, ...
        'hour', {{'hour', 'Hour', 'HO', 'Ho', 'ho', 'HR', 'Hr', 'hr'}}, ...
        'minute', {{'minute', 'Minute', 'MIN', 'Min', 'min', 'MI', 'Mi', 'mi'}}, ...
        'second', {{'second', 'Second', 'SEC', 'Sec', 'sec', 'SE', 'Se', 'se'}} ...
    );
    
    % Verify that the required columns are present in the table
    requiredColumns = fieldnames(columnVariants);
    columnIndices = struct();
    
    for i = 1:numel(requiredColumns)
        colNameVariants = columnVariants.(requiredColumns{i});
        colFound = false;
        
        % Check for any of the valid variants in the table
        for j = 1:numel(colNameVariants)
            if ismember(colNameVariants{j}, dataTable.Properties.VariableNames)
                columnIndices.(requiredColumns{i}) = colNameVariants{j};
                colFound = true;
                break;
            end
        end
        
        if ~colFound
            error("The table must contain one of the columns: %s.", strjoin(colNameVariants, ', '));
        end
    end
    
    % Extract the required components using the detected column names
    years = dataTable.(columnIndices.year);
    months = dataTable.(columnIndices.month);
    days = dataTable.(columnIndices.day);
    hours = dataTable.(columnIndices.hour);
    minutes = dataTable.(columnIndices.minute);
    seconds = dataTable.(columnIndices.second);

    % Convert all components to integers (for year, month, day, hour, minute)
    years = int32(years);
    months = int32(months);
    days = int32(days);
    hours = int32(hours);
    minutes = int32(minutes);
    
    % Ensure seconds are treated as decimal values (do not convert to int32)
    % No need for conversion to integers here as seconds can have decimal values.
    
    % Create datetime objects using the extracted components
    originTime = datetime(years, months, days, hours, minutes, seconds, ...
                          'Format', 'yyyy-MM-dd''T''HH:mm:ss.SSSSSS');
    
    % Add the new column to the table
    dataTable.origin_time = originTime;
end
