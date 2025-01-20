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

function results = calculateEIV(x, y, Su_values, Se_values)
    % calculateEIV - Calculates the  Error-in-Variables (EIV) regression 
    % model parameters and their associated errors, returning them in a table.
    %
    % This function calculates the parameters of a linear regression model 
    % using the Error-in-Variables (EIV) method, which accounts for measurement 
    % errors in both the dependent (y) and independent (x) variables. 
    % The model is defined as:
    %       y = a_EIV + b_EIV * x
    % where:
    %   - a_EIV is the intercept.
    %   - b_EIV is the slope (regression coefficient).
    %
    % Input:
    %   x: vector of values for the independent variable.
    %   y: vector of values for the dependent variable.
    %   Su_values: vector of standard deviation values for the measurement
    %              error of x.
    %          
    %   S2e_values: vector of standard deviation values for the measurement   
    %               error of y
    %
    % Output:
    %   results: table containing the regression parameters (a_EIV, b_EIV) 
    %            and their associated errors, along with the input standard 
    %            deviations (Su, Se) and the number of data points (N) used 
    %            for each calculation.
    
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

    % Calculate the means of x and y
    mean_y = mean(y);
    mean_x = mean(x);
            
    % Calculate the variance of the independent variable x
    S2x = var(x);
    
    % Calculate the covariance between x and y
    Sxy = cov(x, y);
    Sxy = Sxy(1, 2);  % Extract the covariance value from the covariance matrix

    % Calculate the variance of y
    S2y = var(y);
    
    % Preallocate a results table to store the values for each combination of Su and Se
    num_u = length(Su_values);  % Number of standard deviations for x 
    num_e = length(Se_values);   % Number of standard deviations for y 
    
    
    % Populate the table for each combination of Se (std error of y) and Su (std error of x)
    tablesArray = cell(1, num_e * num_u);
    index = 1; % Indice per la cell array unidimensional
    for j = 1:num_e
        Se = Se_values(j);  % Standard deviation of errors on y
        S2e = Se^2;  % Calculate the variance of errors on y
        for i = 1:num_u
            % Standard deviation of errors on x
            Su = Su_values(i);

            % Calculate the variance of errors on x
            S2u = Su^2;
                       
            % Calculate the ratio eta = S2e / S2u, which is used in the EIV model
            eta = S2e / S2u;
            
            % Calculate the slope coefficient (b_EIV) using the Errors-in-Variables method
            b_EIV = (S2y - (eta * S2x) + sqrt((S2y - (eta * S2x))^2 + (4 * eta * Sxy^2))) / ...
                (2 * Sxy);
              
            % Calculate the intercept (a_EIV) using the Errors-in-Variables method
            a_EIV = mean_y - b_EIV * mean_x;
    
            % Calculate the errors on the parameters (Fuller 1987, Lolli & Gasperini 2012)
            sigma_uu = (S2y + eta * S2x - sqrt((S2y - eta * S2x)^2 + 4 * eta * Sxy^2)) /...
                (2 * eta);
            sigma_xx = (sqrt((S2y - eta * S2x)^2 + 4 * eta * Sxy^2) - (S2y - eta * S2x)) / ...
                (2 * eta);
            
            % Calculate the error in b_EIV (err_b) and a_EIV (err_a) 
            sigma2 = ((length(x) - 1) * (eta + b_EIV^2) * sigma_uu) / (length(x) - 2);
            err_b = sqrt((S2x * sigma2 - b_EIV^2 * sigma_uu^2) / ((length(x) - 1) * ...
                sigma_xx^2));
            err_a = sqrt((sigma2 / length(x)) + mean_x^2 * err_b^2);
    
            % Create a temporary row with the current data
            temp_row = table(Se, Su, a_EIV, err_a, b_EIV, err_b, ...
                             'VariableNames', {'std_e', 'std_u', 'a_EIV', 'err_a_EIV', 'b_EIV',...
                             'err_b_EIV'});
            
             % Store the temporary row in the cell array
            tablesArray{index} = temp_row;
            index = index + 1; % Increment the index for the next row
        end
    end

    % Concatenate all the temporary rows into a single table
    results = vertcat(tablesArray{:});
end
