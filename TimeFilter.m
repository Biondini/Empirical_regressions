% Copyright (C) 2024:
% Alma Mater Studiorum Università di Bologna, UNIBO, Bologna, Italy.
% Istituto Nazionale di Geofisica e Vulcanologia, Sezione di Bologna, 
% Italy.
% This program is free software: you can redistribute it and/or modify it
% under  the terms of MIT License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% opinion) any later version. 
%
%This program is distributed in the hope that it will be useful, but
%WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
% or FITNESS FOR A PARTICULAR PORPOSE. See the GNU Affero General Public
% License for more details. 
%
%You should have recieved a copy of the GNU Affero General Public License
%along with this program. If not, see http://www.gnu.org/licenses/.

function [time_filtered_catalog] = TimeFilter(catalog, start_time_str, end_time_str)
    %%%
    % TIMEFILTER Filters events based on the specified time range. If a column with
    % ISO 8601 datetime format is present, it is used as 'origintime'. Otherwise,
    % the function creates 'origintime' from individual date components.
    %
    %   filtered_catalog = TimeFilter(catalog, start_time_str, end_time_str)
    %   returns a table containing only the events that occurred between 
    %   start_time_str and end_time_str. The time strings must be in the 
    %   format 'yyyy-MM-dd''T''HH:mm:ss' (ISO 8601).
    %
    %   Parameters:
    %       - catalog: The table containing the events, potentially with an ISO 8601 
    %                  formatted datetime column or individual date components.
    %       - start_time_str: The start time as a string in the format 'yyyy-MM-dd''T''HH:mm:ss'.
    %       - end_time_str: The end time as a string in the format 'yyyy-MM-dd''T''HH:mm:ss'.
    %
    %   Returns:
    %       - time_filtered_catalog: A table containing only the events within the specified 
    %         time range.
    %%%

    % Check for a column that matches the ISO 8601 datetime format
    origintime_col = '';
    for i = 1:width(catalog)
        col_data = catalog{:, i};
        if isdatetime(col_data)
            origintime_col = catalog.Properties.VariableNames{i};
            break;
        elseif iscellstr(col_data) || isstring(col_data)
            try
                % Attempt to convert to datetime using ISO 8601 format
                datetime_check = datetime(col_data, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
                if all(~isnat(datetime_check))  % Check if all converted successfully
                    origintime_col = catalog.Properties.VariableNames{i};
                    break;
                end
            catch
                % Ignore columns that can't be converted to ISO 8601 datetime
            end
        end
    end

    % If an 'origintime' column wasn't found, create one from individual components
    if isempty(origintime_col)
        % List of possible column name variations for date components
        year_names = {'year', 'Year', 'YEAR', 'yr', 'Yr', 'YR'};
        month_names = {'month', 'Month', 'MONTH', 'mo', 'Mo', 'MO'};
        day_names = {'day', 'Day', 'DAY', 'dy', 'Dy', 'DY', 'da', 'Da', 'DA'};
        hour_names = {'hour', 'Hour', 'HOUR', 'hr', 'Hr', 'HR', 'ho', 'Ho', 'HO'};
        minute_names = {'minute', 'Minute', 'MINUTE', 'min', 'Min', 'MIN', 'mi', 'Mi', 'MI'};
        second_names = {'second', 'Second', 'SECOND', 'sec', 'Sec', 'SEC', 'se', 'Se', 'SE'};

        % Find the actual column names for date components
        year_col = findColumn(catalog, year_names);
        month_col = findColumn(catalog, month_names);
        day_col = findColumn(catalog, day_names);
        hour_col = findColumn(catalog, hour_names);
        minute_col = findColumn(catalog, minute_names);
        second_col = findColumn(catalog, second_names);

        % Validate that all necessary columns were found
        if isempty(year_col) || isempty(month_col) || isempty(day_col) || ...
           isempty(hour_col) || isempty(minute_col) || isempty(second_col)
            error('The catalog table must contain columns for year, month, day, hour, minute, and second.');
        end

        % Create the 'origintime' column from the individual date components
        catalog.origintime = datetime(catalog.(year_col), catalog.(month_col), catalog.(day_col), ...
                                      catalog.(hour_col), catalog.(minute_col), catalog.(second_col), ...
                                      'Format', 'yyyy-MM-dd''T''HH:mm:ss.SSSSSS');
        origintime_col = 'origintime';
    end

    % Convert the time strings to datetime objects
    start_time = datetime(start_time_str, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
    end_time = datetime(end_time_str, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
    
    % Filter the table based on the time range
    time_filtered_catalog = catalog(catalog.(origintime_col) >= start_time & ...
                                    catalog.(origintime_col) <= end_time, :);
end

% Helper function to find the matching column name in a table
function colName = findColumn(table, possibleNames)
    colName = '';
    for i = 1:length(possibleNames)
        if ismember(possibleNames{i}, table.Properties.VariableNames)
            colName = possibleNames{i};
            break;
        end
    end
end
