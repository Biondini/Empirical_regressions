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

function results = calculateOLS(x, y, Su_values, Se_values)
    % CALCULATEOLS Calculates the OLS regression parameters and returns the results in a table.
    %   This function calculates the ordinary least squares (OLS) regression parameters
    %   for the model:
    %       y = a_OLS + b_OLS * x
    %   The function calculates a_OLS and b_OLS based on the input data x and y,
    %   and returns a table with the results including standard errors for the estimates.
    %   The standard deviations of the errors for x (Su_values) and y (Se_values) 
    %   are only used to populate the results table, not for the OLS calculation.
    %
    %   Input:
    %       x: vector of values for the independent variable (x)
    %       y: vector of values for the dependent variable (y)
    %       Su_values: vector of standard deviations of errors on x (Su)
    %       Se_values: vector of standard deviations of errors on y (Se)
    %
    %   Output:
    %       results: table containing the values of standard deviations, a_OLS, b_OLS, and
    %       their standard errors
    
    % Convert x and y to numeric if they are cell arrays
    if iscell(x)
        x = str2double(x); % Convert x to numeric
        if any(isnan(x))
            warning('Some values in the x input were non-numeric and have been replaced with NaN.');
        end
    end
    
    if iscell(y)
        y = str2double(y); % Convert y to numeric
        if any(isnan(y))
            warning('Some values in the y input were non-numeric and have been replaced with NaN.');
        end
    end

    % Calculate the variance of x and y
    S2x = var(x);
    
    % Calculate the covariance between x and y
    Sxy = cov(x, y);
    Sxy = Sxy(1, 2); % Extract the covariance value from the covariance matrix
    
    % Calculate b_OLS (slope coefficient)
    b_OLS = Sxy / S2x;
    
    % Calculate the mean of y and x
    mean_y = mean(y);
    mean_x = mean(x);
    
    % Calculate a_OLS (intercept)
    a_OLS = mean_y - b_OLS * mean_x;
    
    % Calculate the residual sum of squares (SSE)
    residuals = y - (a_OLS + b_OLS * x);
    SSE = sum(residuals.^2);
    
    % Calculate sigma (standard deviation of residuals)
    sigma = sqrt(SSE / (length(x) - 2));
    
    % Calculate sxx (sum of squares of x)
    sxx = sum((x - mean_x).^2);
    
    % Calculate standard error of b_OLS
    err_b = sigma / sqrt(sxx);
    
    % Calculate standard error of a_OLS
    err_a = sigma * sqrt((1 / length(x)) + (mean_x^2 / sxx));
    
    % Preallocate the results table with the correct number of rows
    num_u = length(Su_values);  % Number of standard deviations for x
    num_e = length(Se_values);  % Number of standard deviations for y
             
    % Create a cell array to store tables for each combination of Su and Se
    tablesArray = cell(1, num_e * num_u);
    index = 1; % Index for the cell array

     % Calculate the covariance between the intercept (a_EIV) and the slope (b_EIV)
     cov_a_b = - mean(x) *err_b^2;

    for j = 1:num_e
        Se = Se_values(j); % Standard deviation of errors on y
        for i = 1:num_u
            Su = Su_values(i); % Standard deviation of errors on x
    
            % Create a temporary row for the current combination of Se and Su
            temp_row = table(Se, Su, a_OLS, err_a, b_OLS, err_b, cov_a_b, ...
                             'VariableNames', {'std_e', 'std_u', 'a_OLS', 'err_a_OLS', ...
                             'b_OLS', 'err_b_OLS', 'Cov_a_OLS_b_OLS'});
            
            % Save the temporary row into the cell array
            tablesArray{index} = temp_row;
            index = index + 1; % Increment the index for the next entry
        end
    end
    % Concatenate all the temporary rows into a single table
    results = vertcat(tablesArray{:});
end
