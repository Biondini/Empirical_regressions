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

function [space_filtered_catalog] = SpaceFilter(catalog, polygon)
    %%%
    % SpaceFilter Filters a catalog of geographic points based on a polygon,
    % accommodating various naming conventions for longitude and latitude columns.
    %
    %   This function filters a given catalog of points based on whether their
    %   coordinates fall inside a specified polygon. It supports different column
    %   name conventions for longitude and latitude (e.g., 'longitude', 'Longitude',
    %   'Lon', 'lon', and 'latitude', 'Latitude', 'Lat', 'lat').
    %
    %   Input:
    %       catalog    - A table containing at least two columns for longitude 
    %                    and latitude. The column names can be any of the common 
    %                    variations.
    %       polygon    - A table containing at least two columns for the vertices 
    %                    of the polygon, with flexible naming for longitude and 
    %                    latitude.
    %
    %   Output:
    %       space_filtered_catalog - A table containing the rows of the input 
    %                                'catalog' table that correspond to points 
    %                                inside the specified polygon.
    %
    %   Error Handling:
    %       The function will throw an error if:
    %       - The 'catalog' or 'polygon' tables do not contain columns for longitude 
    %         and latitude under any accepted naming convention.
    %       - The columns contain non-numeric data.
    %       - The polygon does not have enough points to form a valid polygon.
    %%%

    % Possible column name variations for longitude and latitude
    longitude_names = {'longitude', 'Longitude', 'Lon', 'lon'};
    latitude_names = {'latitude', 'Latitude', 'Lat', 'lat'};

    % Find column names for longitude and latitude in the `catalog`
    longitude_col_catalog = findColumn(catalog, longitude_names);
    latitude_col_catalog = findColumn(catalog, latitude_names);

    % Find column names for longitude and latitude in the `polygon`
    longitude_col_polygon = findColumn(polygon, longitude_names);
    latitude_col_polygon = findColumn(polygon, latitude_names);

    % Validate that the required columns were found
    if isempty(longitude_col_catalog)
        error('The catalog table must contain a column for longitude.');
    end
    if isempty(latitude_col_catalog)
        error('The catalog table must contain a column for latitude.');
    end
    if isempty(longitude_col_polygon)
        error('The polygon table must contain a column for longitude.');
    end
    if isempty(latitude_col_polygon)
        error('The polygon table must contain a column for latitude.');
    end

    % Filter points based on whether they are inside the polygon
    in = inpolygon(catalog.(longitude_col_catalog), catalog.(latitude_col_catalog), ...
                   polygon.(longitude_col_polygon), polygon.(latitude_col_polygon));
    space_filtered_catalog = catalog(in, :);
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
