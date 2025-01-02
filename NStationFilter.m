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

function n_station_filtered_catalog = NStationFilter(catalog, n_station_vec, min_number_of_station)
    % NStationFilter Filters an earthquake catalog based on the minimum number of recording stations.
    %
    %   This function filters a given earthquake catalog by including only 
    %   events recorded by a specified minimum number of stations.
    %
    %   Input:
    %       catalog               - A table containing earthquake event data, 
    %                               where each row represents an event.
    %       n_station_vec         - A table or array with the same number of rows as 
    %                               'catalog', containing the number of stations 
    %                               that recorded each event.
    %       min_number_of_station - A numeric value specifying the minimum number 
    %                               of stations required to include an event in 
    %                               the output.
    %
    %   Output:
    %       n_station_filtered_catalog - A table containing only the rows from 
    %                                    'catalog' that were recorded by at least 
    %                                    'min_number_of_station' stations.
    %
    %   Error Handling:
    %       The function will throw an error if:
    %       - The number of rows in 'catalog' and 'n_station_vec' are not equal.
    %
    %   Example:
    %       filtered_catalog = NStationFilter(catalog, n_station_vec, 5);
    %       This returns only the events in 'catalog' that were recorded by 5 
    %       or more stations.

    % Check if catalog and n_station_vec have the same number of rows
    if height(catalog) ~= numel(n_station_vec)
        error('The number of rows in catalog and n_station_vec must be the same.');
    end

    % Convert n_station_vec to numeric if it is a cell array
    if iscell(n_station_vec)
        n_station_vec = str2double(n_station_vec); % Convert cell array to numeric
        % Replace non-convertible values with NaN (handled automatically by str2double)
        if any(isnan(n_station_vec))
            warning('Some values in the n_station_vec were non-numeric and have been replaced with NaN.');
        end
    end

    % Filter events that were recorded by at least min_number_of_station stations
    filter_idx = n_station_vec >= min_number_of_station;
    
    % Apply the filter to the earthquake catalog
    n_station_filtered_catalog = catalog(filter_idx, :);
end
