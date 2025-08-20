% Copyright (C) 2024:
% Alma Mater Studiorum Università di Bologna, UNIBO, Bologna, Italy.
% Istituto Nazionale di Geofisica e Vulcanologia, Sezione di Bologna, 
% Italy.
% This program is free software: you can redistribute it and/or modify it
% under the terms of MIT License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% opinion) any later version. 
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
% or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public
% License for more details. 
%
% You should have received a copy of the GNU Affero General Public License
% along with this program. If not, see http://www.gnu.org/licenses/.

% Clearing workspace, closing figures, and clearing command window
clear 
close all
warning('off', 'all');
clc


% Adding utility functions to the MATLAB path
% addpath('./utils');

% Importing the data:
% Load the earthquake catalog and the New Zealand Testing Region
CatNSHM=readtable("./data/Cat_NSHM_magnitudes-revised_August22.csv"); % Earthquake catalog
NZTestingRegion=readtable("./data/NZ_Testing_Center_Region.txt");  % New Zealand Testing Center polygon (TCP)

% Add the `origin_time` column indicating the origin time of each event in
% ISO 8601 format.
CatNSHM = addISO8601Time(CatNSHM);

% --- Space filter: restrict data to events within the testing region ---
% Apply a space filter to only consider events within the defined region (TCP)
[space_filtered_catalog] = SpaceFilter(CatNSHM, NZTestingRegion);

% --- Temporal filter: restrict data to events within a given time range ---
% Define the start and end times for the temporal filter in ISO 8601 format
start_time_str = "2004-01-01T00:00:00";
end_time_str = "2020-12-31T23:59:59";
% Apply the temporal filter
[time_filtered_catalog] = TimeFilter(space_filtered_catalog, start_time_str, end_time_str);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Regression of MwNZ (New Zealand Moment Magnitude) on MLNZ77 (Local Magnitude)
% Create a subset of data from 2004-2011, filtered by depth, magnitude, and station count

% Subset the data from 2004 to 2011
ml_nz = TimeFilter(time_filtered_catalog, "2004-01-01T00:00:00", "2011-12-31T23:59:59");

% Filter shallow events between depths of -10 and 40 km
ml_nz_shallow1 = DepthFilter(ml_nz, -10, 40);

% Select events with MwNZ (moment magnitude)
mwnz = ml_nz_shallow1(ml_nz_shallow1.Mpref_type == "Mwnz", :);

% Filter for magnitudes within the range [4.55, 6.5]
ml_nz_shallow1 = MagnitudeFilter(ml_nz_shallow1, ml_nz_shallow1.ML, 4.55, 6.5);

% Remove following events with specific magnitude differences
catalog_2004_2012 = RemoveFollowingEarthquakes(ml_nz_shallow1, mwnz, 'origin_time', ...
    'origin_time', 'Mpref', [7.0, 6.0, 5.0, 0], [4, 2, 1, 0.5]);

% Filter for only events with MwNZ type
catalog_2004_2012 = catalog_2004_2012(catalog_2004_2012.Mpref_type == "Mwnz", :);

% Apply a station count filter (only events with more than 12 stations)
catalog_2004_2012 = NStationFilter(catalog_2004_2012, catalog_2004_2012.ML_station_count, 12);

% Standard deviations for ML and Mw magnitudes, used in regression models
Sml = [0.024, 0.045, 0.07, 0.1, 0.12, 0.15, 0.18, 0.2];  % Standard deviations for ML
Smw = [0.2, 0.1];  % Standard deviations for Mw

% Perform Ordinary Least Squares (OLS) regression
table_OLS = calculateOLS(catalog_2004_2012.ML, catalog_2004_2012.Mpref, Sml, Smw);

% Perform Maximum Likelihood (MM) regression
table_MM = calculateMM(catalog_2004_2012.ML, catalog_2004_2012.Mpref, Sml, Smw);

% Perform Errors-in-Variables (EIV) regression
table_EIV = calculateEIV(catalog_2004_2012.ML, catalog_2004_2012.Mpref, Sml, Smw);

% Perform corrected EIV regression considering earthquake error
table_EIVcorr = calculateEIV_eqerror(catalog_2004_2012.ML, catalog_2004_2012.Mpref, Sml, Smw);

% Merge the regression tables
Regression_Table = MergeTables(table_OLS, table_MM, table_EIVcorr);

% Save the regression table in both .csv and .xlsx formats
% Define file paths
csvFilename = fullfile('./results', 'Regression_Table_2004_2012.csv');
xlsxFilename = fullfile('./results', 'Regression_Table_2004_2012.xlsx');
tempXlsxFilename = fullfile('./results', 'temp.xlsx');  % Temporary file

% Write to CSV file
fclose(fopen(csvFilename, 'w'));  % Reset the CSV file
writetable(Regression_Table, csvFilename);  % Write data to the CSV file

% Write to XLSX file
writetable(Regression_Table, tempXlsxFilename);  % Write data to the temporary file
movefile(tempXlsxFilename, xlsxFilename);  % Replace the original file with the temporary file

% Create a graph to visualize the regression slope
CreateGraphSlope(Regression_Table, 'M_{wNZ} - M_{LNZ77}');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Regression of MwNZ (New Zealand Moment Magnitude) on MLSC3 (Local Magnitude for 2012-2020)
% Create a new subset of data from 2012 to 2020, following similar filtering

% Subset the data from 2012 to 2020
ml_nz = TimeFilter(time_filtered_catalog, "2012-01-01T00:00:00", "2020-12-31T23:59:59");
ml_nz_shallow1 = DepthFilter(ml_nz, -10, 40);
mwnz = ml_nz_shallow1(ml_nz_shallow1.Mpref_type == "Mwnz", :);
ml_nz_shallow1 = MagnitudeFilter(ml_nz_shallow1, ml_nz_shallow1.ML, 4.55, 6.5);
catalog_2012_2021 = RemoveFollowingEarthquakes(ml_nz_shallow1, mwnz, 'origin_time', ...
    'origin_time', 'Mpref', [7.0, 6.0, 5.0, 0], [4, 2, 1, 0.5]);
catalog_2012_2021 = catalog_2012_2021(catalog_2012_2021.Mpref_type == "Mwnz", :);
catalog_2012_2021 = NStationFilter(catalog_2012_2021, catalog_2012_2021.ML_station_count, 12);

% Perform regression steps as in the previous block
table_OLS = calculateOLS(catalog_2012_2021.ML, catalog_2012_2021.Mpref, Sml, Smw);
table_MM = calculateMM(catalog_2012_2021.ML, catalog_2012_2021.Mpref, Sml, Smw);
table_EIV = calculateEIV(catalog_2012_2021.ML, catalog_2012_2021.Mpref, Sml, Smw);
table_EIVcorr = calculateEIV_eqerror(catalog_2012_2021.ML, catalog_2012_2021.Mpref, Sml, Smw);

% Merge the regression tables for this period
Regression_Table = MergeTables(table_OLS, table_MM, table_EIVcorr);

% Save the regression table for this period
% Define file paths
csvFilename = fullfile('./results', 'Regression_Table_2012_2021.csv');
xlsxFilename = fullfile('./results', 'Regression_Table_2012_2021.xlsx');
tempXlsxFilename = fullfile('./results', 'temp.xlsx');  % Temporary file

% Write to CSV file
fclose(fopen(csvFilename, 'w'));  % Reset the CSV file
writetable(Regression_Table, csvFilename);  % Write data to the CSV file

% Write to XLSX file
writetable(Regression_Table, tempXlsxFilename);  % Write data to the temporary file
movefile(tempXlsxFilename, xlsxFilename);  % Replace the original file with the temporary file

% Create a graph for this regression slope
CreateGraphSlope(Regression_Table, 'M_{wNZ} - M_{LCS3}');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Regression of MwMT (Moment Magnitude from HORUS) on MLIside (Local Magnitude from Italy)
% Load Italian earthquake data and perform regression similar to above

% Load the Italian HORUS data
HORUSItaDataOrigin = readtable("./data/HORUS_Ita_DataOrigin.txt");

% Add the `origin_time` column indicating the origin time of each event in
% ISO 8601 format.
HORUSItaDataOrigin = addISO8601Time(HORUSItaDataOrigin);

% Define time range for analysis (from 2005 to 2023)
time_start = "2005-04-16T00:00:00";
time_end = "2023-12-31T23:59:59";
HORUSItaDataOrigin = TimeFilter(HORUSItaDataOrigin, time_start, time_end);

% Filter for events originating in Italy
HORUSItaDataOrigin = HORUSItaDataOrigin(HORUSItaDataOrigin.Italia == "*", :);

% Apply magnitude and depth filters
HORUSItaDataOrigin = MagnitudeFilter(HORUSItaDataOrigin, HORUSItaDataOrigin.ML, 3);
HORUSItaDataOrigin = MagnitudeFilter(HORUSItaDataOrigin, HORUSItaDataOrigin.Mw_MT, 0);
HORUSItaDataOrigin = DepthFilter(HORUSItaDataOrigin, -10, 40);
mwmt=HORUSItaDataOrigin;
HORUSItaDataOrigin = RemoveFollowingEarthquakes(HORUSItaDataOrigin, mwmt, 'origin_time', ...
    'origin_time', 'Mw_MT', [7.0, 6.0, 5.0, 0], [4, 2, 1, 0.5]);

% Standard deviations for ML and Mw magnitudes, used in regression models
Sml = [0.024, 0.045, 0.07, 0.1, 0.12, 0.15, 0.18, 0.2];  % Standard deviations for ML
Smw = [0.2, 0.1];  % Standard deviations for Mw

% Perform regression for this dataset
table_OLS = calculateOLS(HORUSItaDataOrigin.ML, HORUSItaDataOrigin.Mw_MT, Sml, Smw);
table_MM = calculateMM(HORUSItaDataOrigin.ML, HORUSItaDataOrigin.Mw_MT, Sml, Smw);
table_EIV = calculateEIV(HORUSItaDataOrigin.ML, HORUSItaDataOrigin.Mw_MT, Sml, Smw);
table_EIVcorr = calculateEIV_eqerror(HORUSItaDataOrigin.ML, HORUSItaDataOrigin.Mw_MT, Sml, Smw);

% Merge the regression tables for this data
Regression_Table = MergeTables(table_OLS, table_MM, table_EIVcorr);

% Save the regression table for this period
% Define file paths
csvFilename = fullfile('./results', 'Regression_Table_2005_2023Horus.csv');
xlsxFilename = fullfile('./results', 'Regression_Table_2005_2023Horus.xlsx');
tempXlsxFilename = fullfile('./results', 'temp.xlsx');  % Temporary file

% Write to CSV file
fclose(fopen(csvFilename, 'w'));  % Reset the CSV file
writetable(Regression_Table, csvFilename);  % Write data to the CSV file

% Write to XLSX file
writetable(Regression_Table, tempXlsxFilename);  % Write data to the temporary file
movefile(tempXlsxFilename, xlsxFilename);  % Replace the original file with the temporary file


% Create a graph for this regression slope
CreateGraphSlope(Regression_Table, 'M_{w} - M_{LISIDe}');

