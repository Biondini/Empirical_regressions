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

function results = calculateMM(x, y, Su_values, Se_values) 
    % Calculates the MM regression parameters and returns the results in a table.
    %   This function calculates the parameters of the regression model using the
    %   Method of Moments (MM). The model is defined as:
    %       y = a_MM + b_MM * x
    %   The function calculates a_MM and b_MM for each value of the standard deviations 
    %   provided in Su_values and returns a table with the results.
    %   The standard deviations of the errors for y (Se_values) 
    %   are only used for populating the results table, not for the MM calculations.
    %
    %   Input:
    %       x: vector of values for the independent variable (ML)
    %       y: vector of values for the dependent variable (Mpref)
    %       Su_values: vector of standard deviation values for x 
    %       Se_values: vector of standard deviation values for x 
    %
    %    Output:
    %       results: table containing the values of standard deviations, a_MM, b_MM, and their 
    %       standard errors
    
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

    % Calculate the variance of x
    S2x = var(x);
    
    % Calculate the covariance between x and y
    Sxy = cov(x, y);
    Sxy = Sxy(1, 2); % Extract the covariance value from the covariance matrix
    
    % Preallocate the results table with the correct number of rows
    num_u = length(Su_values);  % Number of standard deviations for x 
    num_e = length(Se_values);  % Number of standard deviations for y 
    
    % Create a cell array to store tables for each combination of Su and Se
    tablesArray = cell(1, num_e * num_u);
    index = 1; % Indice per la cell array unidimensional

    % Populate the table for each combination of Se and Su
    for j = 1:num_e
        Se = Se_values(j);
        for i = 1:num_u
            % Get the current value of S2u (which is standard deviation)
            Su = Su_values(i);
            
           % Calculate the variance from standard deviation Su
            S2u = Su^2;
            
            % Calculate b_MM (slope coefficient using the Method of Moments)
            b_MM = Sxy / (S2x - S2u);
            
            % Calculate the mean of y and x
            mean_y = mean(y);
            mean_x = mean(x);
            
            % Calculate a_MM (intercept using the Method of Moments)
            a_MM = mean_y - b_MM * mean_x;
            
            % Calculate the residual sum of squares for MM (S2v)
            S2v = sum((y - mean(y) - (x - mean(x)).*b_MM).^2)/(length(x)-2);

            % Calculate standard error of b_MM
            err_b = sqrt((S2x*S2v+b_MM^2*S2u^2)/((S2x-S2u)^2*(length(x)-1)));
               
            % Calculate standard error of a_MM
            err_a = sqrt(err_b^2 * mean(x)^2 + S2v/length(x));

             % Calculate the covariance between the intercept (a_EIV) and the slope (b_EIV)
            cov_a_b = - mean(x) *err_b^2;
            
             % Create a temporary row with the current data
            temp_row = table(Se, Su, a_MM, err_a, b_MM, err_b, cov_a_b, ...
                             'VariableNames', {'std_e', 'std_u', 'a_MM', 'err_a_MM', 'b_MM',...
                             'err_b_MM', 'Cov_a_MM_b_MM'});
            
            % Save the temporary row into the cell array
            tablesArray{index} = temp_row;
            index = index + 1; % Increment the index for the next entry
        end
    end
    
    % Concatenate all the temporary rows into a single table
    results = vertcat(tablesArray{:});
end
