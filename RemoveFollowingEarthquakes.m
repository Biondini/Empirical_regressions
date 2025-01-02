function filtered_catalog = RemoveFollowingEarthquakes(catalog1, catalog2, time_col1, time_col2, mag_col2, mag_thresholds, time_windows)
    % RemoveFollowingEarthquakes Removes events from catalog1 based on events in catalog2.
    %
    %   This function takes two earthquake catalogs (as tables) and removes events
    %   from catalog1 that occur within a specified time window following any
    %   earthquake in catalog2 with a magnitude greater than a certain threshold.
    %
    %   The removal windows based on magnitude are specified by the `mag_thresholds`
    %   and `time_windows` parameters:
    %       mag_thresholds - A vector of magnitude thresholds (e.g., [7.0, 6.0, 5.0]).
    %       time_windows   - A vector of corresponding time windows in hours (e.g., [4, 2, 1, 0.5]).
    %
    %   Input:
    %       catalog1   - A table representing the main catalog from which events are to be removed.
    %       catalog2   - A table representing the secondary catalog with earthquake events
    %                    to be used as reference for removal.
    %       time_col1  - The name of the column in catalog1 containing event times (as datetime or string).
    %       time_col2  - The name of the column in catalog2 containing event times (as datetime or string).
    %       mag_col2   - The name of the column in catalog2 containing event magnitudes (numeric).
    %       mag_thresholds - A vector specifying the magnitude thresholds for removal (numeric values).
    %       time_windows   - A vector specifying the corresponding time windows for each magnitude threshold (numeric values, in hours).
    %
    %   Output:
    %       filtered_catalog - A table containing events from catalog1 with specified
    %                          events removed.
    %
    %   Notes:
    %       - The function assumes that the time columns in both catalogs are in datetime format or can be converted to datetime.
    %       - The magnitude thresholds and corresponding time windows should be ordered, with larger magnitudes having longer removal windows.
    
    % Validate inputs
    if ~ismember(time_col1, catalog1.Properties.VariableNames) || ~ismember(time_col2, catalog2.Properties.VariableNames)
        error('Both catalogs must have the specified time columns.');
    end
    if ~ismember(mag_col2, catalog2.Properties.VariableNames)
        error('Catalog2 must have the specified magnitude column.');
    end
    if length(mag_thresholds) ~= length(time_windows)
        error('Magnitude thresholds and time windows must have the same length.');
    end

    % Ensure times are in datetime format
    catalog1.(time_col1) = datetime(catalog1.(time_col1), 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSSSS', 'TimeZone', 'UTC');
    catalog2.(time_col2) = datetime(catalog2.(time_col2), 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSSSS', 'TimeZone', 'UTC');

    % Initialize the logical index to keep track of which rows to retain
    retain_idx = true(height(catalog1), 1);

    % Loop through each event in catalog2 and apply the removal logic
    for i = 1:height(catalog2)
        event_time = catalog2.(time_col2)(i);
        event_magnitude = catalog2.(mag_col2)(i);

        % Determine the time window based on magnitude thresholds
        time_window = NaN;
        for j = 1:length(mag_thresholds)
            if event_magnitude > mag_thresholds(j)
                time_window = time_windows(j);
                break;
            end
        end
        
        % If magnitude is below all thresholds, skip the event
        if isnan(time_window)
            continue;
        end

        % Create a logical index for events within the time window in catalog1
        removal_idx = (catalog1.(time_col1) > event_time) & (catalog1.(time_col1) <= event_time + hours(time_window));

        % Update the index to retain only events outside these windows
        retain_idx = retain_idx & ~removal_idx;
    end

    % Apply the filter to catalog1
    filtered_catalog = catalog1(retain_idx, :);
end
