% Copyright (C) 2024:
% Alma Mater Studiorum Università di Bologna, UNIBO, Bologna, Italy.
% Istituto Nazionale di Geofisica e Vulcanologia, Sezione di Bologna, 
% Italy.
% This program is free software: you can redistribute it and/or modify it
% under  the terms of MIT License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% opinion) any later version. 
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
% or FITNESS FOR A PARTICULAR PORPOSE. See the GNU Affero General Public
% License for more details. 
%
% You should have recieved a copy of the GNU Affero General Public License
% along with this program. If not, see http://www.gnu.org/licenses/.

function depth_filtered_catalog = DepthFilter(catalog, depth_min, depth_max)
    % DEPTHFILTER Filters an earthquake catalog based on depth range.
    %
    %   This function filters a given earthquake catalog by including only 
    %   events that have depths within a specified minimum and maximum range.
    %
    %   Input:
    %       catalog   - A table containing earthquake event data, where each 
    %                   row represents an event and includes a 'depth' column 
    %                   or a variant thereof with numeric depth values.
    %       depth_min - A numeric value specifying the minimum depth for filtering.
    %       depth_max - A numeric value specifying the maximum depth for filtering.
    %
    %   Output:
    %       depth_filtered_catalog - A table containing only the rows from 
    %                                'catalog' that have depths within the 
    %                                specified range (depth_min < depth <= depth_max).
    %
    %   Error Handling:
    %       The function will throw an error if:
    %       - depth_min is not less than depth_max.
    %       - No suitable column for depth is found in the catalog.
    %
    %   Example:
    %       filtered_catalog = DepthFilter(catalog, 10, 50);
    %       This returns only the events in 'catalog' with depths between 
    %       10 and 50 units (excluding 10 and including 50).
    
    % Check if depth_min is less than depth_max
    if depth_min >= depth_max
        error('depth_min must be less than depth_max.');
    end

    % List of possible column name variations for depth
    depth_names = {'depth', 'Depth', 'DEPTH', 'dpth', 'Dpth', 'DPTH'};

    % Find the actual column name for depth
    depth_col = findColumn(catalog, depth_names);

    % Validate that a depth column was found
    if isempty(depth_col)
        error('The catalog table must contain a column for depth.');
    end

    % Filter events within the specified depth range
    depth_filtered_catalog = catalog(catalog.(depth_col) > depth_min & catalog.(depth_col) <= depth_max, :);
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
