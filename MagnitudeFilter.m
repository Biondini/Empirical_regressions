function magnitude_filtered_catalog = MagnitudeFilter(catalog, magnitude_vec, varargin)
    % MagnitudeFilter Filters an earthquake catalog based on a target magnitude or range.
    %
    %   This function filters a given earthquake catalog by including only 
    %   events that have a magnitude that meets specified criteria:
    %   - If a single target magnitude is provided, the function includes
    %     only events with a magnitude equal to or greater than the target.
    %   - If two magnitudes are provided, the function includes only events
    %     with magnitudes between the two specified values (inclusive).
    %
    %   Input:
    %       catalog         - A table containing earthquake event data, where each 
    %                         row represents an event.
    %       magnitude_vec   - A table or array with the same number of rows as 
    %                         'catalog', containing the magnitude values of each event.
    %       varargin        - One or two numeric values specifying the magnitude 
    %                         filter criteria. If one value is provided, it is 
    %                         used as the minimum threshold. If two values are provided, 
    %                         they specify the lower and upper bounds of the range.
    %
    %   Output:
    %       magnitude_filtered_catalog - A table containing only the rows from 
    %                                    'catalog' that meet the magnitude filter criteria.
    %
    %   Error Handling:
    %       The function will throw an error if:
    %       - The number of rows in 'catalog' and 'magnitude_vec' are not equal.
    %       - An invalid number of magnitude arguments is provided.
    %
    %   Example:
    %       filtered_catalog = MagnitudeFilter(catalog, magnitude_vec, 4.0);
    %       filtered_catalog = MagnitudeFilter(catalog, magnitude_vec, 4.0, 6.0);
    %       The first example filters for magnitudes >= 4.0.
    %       The second example filters for magnitudes in the range [4.0, 6.0].
    
    % Check if catalog and magnitude_vec have the same number of rows
    if height(catalog) ~= numel(magnitude_vec)
        error('The number of rows in catalog and magnitude_vec must be the same.');
    end

    % Convert magnitude_vec to numeric if it is a cell array
    if iscell(magnitude_vec)
        magnitude_vec = str2double(magnitude_vec); % Convert cell array to numeric
        % Replace non-convertible values with NaN (handled automatically by str2double)
        if any(isnan(magnitude_vec))
            warning('Some values in the magnitude vector were non-numeric and have been replaced with NaN.');
        end
    end

    % Check number of input arguments for magnitude thresholds
    if isscalar(varargin)
        % Single magnitude target provided
        magnitude_target = varargin{1};
        filter_idx = magnitude_vec >= magnitude_target;
    elseif length(varargin) == 2 
        % Two magnitude limits provided
        m1 = varargin{1};
        m2 = varargin{2};
        if m1 > m2
            error(['The first magnitude (m1) must be less than or equal to the second ' ...
                'magnitude (m2).']);
        end
        filter_idx = (magnitude_vec > m1) & (magnitude_vec < m2);
    else
        error(['Invalid number of magnitude arguments. Provide either one or two numeric ' ...
            'values.']);
    end

    % Apply the filter to the earthquake catalog
    magnitude_filtered_catalog = catalog(filter_idx, :);
end
