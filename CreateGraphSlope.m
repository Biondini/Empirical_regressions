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

function CreateGraphSlope(Regression_Table, graphTitle)
    % CREATEGRAPH generates a plot with curves for OLS, MM, and EIV,
    % and saves it as a TIFF image with a filename based on the given title.
    %
    % Syntax:
    %   createGraph(Regression_Table, graphTitle)
    %
    % Input:
    %   - Regression_Table: A table containing regression data.
    %     The table must have the following columns:
    %     - std_u: The input variables for the error.
    %     - b_OLS, b_MM, b_EIV: The estimated coefficients for the OLS, MM, and EIV methods.
    %     - err_b_OLS, err_b_MM, err_b_EIV: The standard errors for each method.
    %     - std_e: The column that specifies sigma values (0.2 and 0.1).
    %
    %   - graphTitle: A string representing the title of the plot. This
    %     will also be used for the output file name (without the extension).
    %     Example: 'MwNZ - MLNZ77'.
    %
    % Side effects:
    %   - Creates a figure containing a plot with 4 curves (OLS, MM, EIV with sigma = 0.2 and 0.1).
    %   - Sets the title and axis labels.
    %   - Saves the plot as a TIFF file with 800 DPI resolution, with the file name based on graphTitle.
    %
    % Example:
    %   createGraph(Regression_Table, 'MwNZ - MLNZ77')
    %   This will create a plot titled 'MwNZ - MLNZ77' and save it as
    %   'MwNZ - MLNZ77.tiff'.
    
    % Filter data for std_e == 0.2 and std_e == 0.1
    Regression_Table20 = Regression_Table(Regression_Table.std_e == 0.2, :);
    Regression_Table10 = Regression_Table(Regression_Table.std_e == 0.1, :);


    % Set the figure size in inches
    fig = figure('Units', 'inches', 'Position', [1, 1, 6, 3.72]);  
    set(fig, 'PaperPositionMode', 'manual'); 
    set(fig, 'PaperPosition', [0, 0, 18, 11.145]);  
    set(fig, 'PaperSize', [18, 11.145]); 

    % Plot the OLS, MM, EIV curves
    errorbar(Regression_Table20.std_u(:), Regression_Table20.b_OLS, Regression_Table20.err_b_OLS, ...
        '-', 'Color', [0, 0.6, 0.2], 'LineWidth', 2, 'DisplayName', 'OLS');
    hold on;
    
    errorbar(Regression_Table20.std_u(:), Regression_Table20.b_MM, Regression_Table20.err_b_MM, ...
        '-', 'Color', [0.4, 0.4, 0.4], 'LineWidth', 2, 'DisplayName', 'MM');
    hold on;
    
    errorbar(Regression_Table20.std_u(:), Regression_Table20.b_EIV, Regression_Table20.err_b_EIV, ...
        '-', 'Color', [0, 0.6, 1], 'LineWidth', 2, 'DisplayName', 'EIV (\sigma_{Mw} = 0.2)');
    hold on;
    
    errorbar(Regression_Table10.std_u(:), Regression_Table10.b_EIV, Regression_Table10.err_b_EIV, ...
        '-', 'Color', [1, 0, 0.2], 'LineWidth', 2, 'DisplayName', 'EIV (\sigma_{Mw} = 0.1)');
    
    % Add legend in the top-left corner
    legend('show', 'Interpreter', 'tex', 'Location', 'northwest');
    
    % Add horizontal grid
    grid on;
    ax = gca;  % Get the current axis object
    ax.XGrid = 'off';  % Disable vertical grid
    ax.YGrid = 'on';   % Enable horizontal grid
    ax.GridAlpha = 1;
    ax.GridLineWidth = 1.5;
    ax.LineWidth = 1.5;
    ax.FontSize = 12;
    ax.FontName = 'Arial';
    
    % Set X-axis limits
    xlim([0, 0.25]);
    
    % Set the title and axis labels
    title(graphTitle);
    ylabel('Slope');
    xlabel('\sigma_{ML}');
   
    % Save the figure with the filename based on the title
    graphTitle =fullfile(".\results", graphTitle);
    fileName = strcat(graphTitle, '.tiff');
    
    print(fig, fileName, '-dtiff', '-r800');
end
