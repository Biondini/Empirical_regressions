function results = calculateEIV_eqerror(x, y, Su_values, Se_values)
    % CALCULATEEIV_EQERROR Calculates the Errors-in-Variables (EIV) regression 
    % parameters, accounting for equation error, and returns the results in a table.
    %
    % This function calculates the parameters of a linear regression model using 
    % the Errors-in-Variables (EIV) method, which accounts for measurement errors 
    % in both the dependent (y) and independent (x) variables, including an 
    % additional consideration for equation error. The model is defined as:
    %       y = a_EIV + b_EIV * x
    % where:
    %   - a_EIV is the intercept
    %   - b_EIV is the slope (regression coefficient)
    %
    % The equation error is included as an additional term (S2q) that is 
    % calculated based on the residuals and measurement errors.
    %
    % Input:
    %   x: vector of values for the independent variable (ML)
    %   y: vector of values for the dependent variable (Mpref)
    %   Su_values: vector of standard deviation values for the measurement error 
    %              in x (these are standard deviations, not squared)
    %   Se_values: vector of standard deviation values for the measurement error 
    %              in y (these are standard deviations, not squared)
    %
    % Output:
    %   results: table containing the regression parameters (a_EIV, b_EIV) and their 
    %            associated errors, along with the input standard deviations (Su, Se), 
    %            the calculated equation error (S2q), and the number of data points (N) 
    %            used for each calculation.
    %
    % The table contains the following columns:
    %   - std_e: standard deviation of errors in y
    %   - std_u: standard deviation of errors in x
    %   - S2q: equation error term
    %   - method: method used ('EIV' or 'EIV_eq_err')
    %   - a_EIVcorr: corrected intercept
    %   - err_a_EIVcorr: error in corrected intercept
    %   - b_EIVcorr: corrected slope
    %   - err_b_EIVcorr: error in corrected slope
    %   - N: number of data points used

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
    Sxy = Sxy(1, 2); % Extract the covariance value from the matrix
    
    % % Calculate the variance of y from the standard deviation S2e
    % S2e_squared = S2e^2;  % Square the value of S2e to get the variance
    
    % Calculate the variance of y
    S2y = var(y);
    
    % Preallocate a results table to store the values for each combination of Su and Se
    num_u = length(Su_values);   % Number of standard deviations for x 
    num_e = length(Se_values);    % Number of standard deviations for y
        
    % Create a temporary cell array to hold the method values (EIV or EIV_eq_err)
    tablesArray = cell(1, num_e * num_u);
    index = 1; % Index for the cell array

    % Loop over each value of Se and Su, calculating the regression parameters
    for j = 1:num_e
        % Standard deviation of errors on y
        Se = Se_values(j);

        % Calculate the variance of errors on y
        S2e = Se^2;
        for i = 1:num_u
            % Standard deviation of errors on x
            Su = Su_values(i);

            % Calculate the variance of errors on x
            S2u = Su^2;
                   
           % Calculate the MM slope coefficient (b_MM) for the current values of Su and Se
            b_MM = Sxy / (S2x - S2u);
            
            % Calculate the residual sum of squares (S2V)
            S2V = (1/(length(x)-2)) * sum((y - mean(y) - b_MM * (x - mean(x))).^2);
            
            % Calculate the equation error term (S2q)
            S2q = S2V - S2e - b_MM^2 * S2u;
            
            if S2q > 0
                % If the equation error term is positive, calculate EIV with equation error
                eta = (S2e + S2q) / S2u;
                b_EIV_corr = (S2y - (eta * S2x) + sqrt((S2y - (eta * S2x))^2 + (4 * eta * ...
                    Sxy^2))) / (2 * Sxy);
                mean_y = mean(y);
                mean_x = mean(x);
                a_EIV_corr = mean_y - b_EIV_corr * mean_x;
                
                % Calculate errors on the parameters (Fuller 1987, Lolli & Gasperini 2012)
                sigma_uu = (S2y + eta * S2x - sqrt((S2y - eta * S2x)^2 + 4 * eta * Sxy^2))...
                    / (2 * eta);
                sigma_xx = (sqrt((S2y - eta * S2x)^2 + 4 * eta * Sxy^2) - (S2y - eta * S2x))...
                    / (2 * eta);
                sigma2 = ((length(x) - 1) * (eta + b_EIV_corr^2) * sigma_uu) / (length(x) - 2);
                err_b_corr = sqrt((S2x * sigma2 - b_EIV_corr^2 * sigma_uu^2) / ((length(x) - 1) * ...
                    sigma_xx^2));
                err_a_corr = sqrt((sigma2 / length(x)) + mean_x^2 * err_b_corr^2);

                % Calculate the covariance between the intercept (a_EIV) and the slope (b_EIV)
                cov_a_b_corr = - mean(x) *err_b_corr^2;

                results_temp = calculateEIV(x, y, Su, Se);  
                
                % Use the results from the regular EIV function
                a_EIV = results_temp.a_EIV(1);
                b_EIV = results_temp.b_EIV(1);
                err_a = results_temp.err_a_EIV(1);
                err_b = results_temp.err_b_EIV(1);
                cov_a_b = - mean(x) *err_b^2;

                
            
            else
                % If S2q <= 0, use the regular EIV function without error
                % Call the function without equation error
                results_temp = calculateEIV(x, y, Su, Se);  
                
                % Use the results from the regular EIV function
                a_EIV = results_temp.a_EIV(1);
                b_EIV = results_temp.b_EIV(1);
                err_a = results_temp.err_a_EIV(1);
                err_b = results_temp.err_b_EIV(1);
                cov_a_b = - mean(x) *err_b^2;
                a_EIV_corr = NaN;
                b_EIV_corr = NaN;
                err_a_corr = NaN;
                err_b_corr = NaN;
                cov_a_b_corr = NaN;
                
            end


            
            % Add the current S2u, a_EIV, b_EIV, err_a, err_b, and S2q values to the table
            % Crea una tabella temporanea con i dati correnti
            temp_row = table(Se, Su, S2q, a_EIV, err_a, b_EIV, err_b, cov_a_b, a_EIV_corr, err_a_corr, b_EIV_corr, err_b_corr, cov_a_b_corr, ...
                 'VariableNames', {'std_e', 'std_u', 'S2q', 'a_EIV', ...
                             'err_a_EIV', 'b_EIV', 'err_b_EIV', 'Cov_a_EIV_b_EIV', ...
                             'a_EIV_corr','err_a_EIV_corr', 'b_EIV_corr', 'err_b_EIV_corr', 'Cov_a_EIV_b_EIV_corr'});
            
            % Save the temporary row in a cell array
            tablesArray{index} = temp_row;
            index = index + 1; % Increment the index for the next row
            
        end
    end

     % Concatenate all the temporary rows into a single table
     results = vertcat(tablesArray{:});
end
