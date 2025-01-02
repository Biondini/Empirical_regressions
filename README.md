<center>
  
# The role of “equation error” in empirical regressions for seismic magnitude conversions
## Paolo Gasperini<sup>1,2</sup>, Barbara Lolli<sup>2,*</sup> and Emanuele Biondini<sup>1</sup>

### <sup>1</sup>Dipartimento di Fisica e Astronomia, Universita’ di Bologna (Italy)
### <sup>2</sup>Istituto Nazionale di Geofisica e Vulcanologia, Sezione di Bologna (Italy)
### <sup>*</sup>Corresponding author
</center>

# Code Overview

The provided code performs a series of analyses on seismic catalogs to study the relationship between different magnitude scales, such as Local Magnitude (ML) and Moment Magnitude (Mw), using various regression methods. Below is an overview of the main sections of the code:

## 1. **Data Loading and Preparation:**
- The seismic catalog data and the polygon of the testing region are loaded.
- A new column, `origin_time`, is added, which indicates the origin time of each seismic event in ISO 8601 format.

## 2. **Spatial and Temporal Filtering:**
- A spatial filter is applied to consider only events within the defined testing region.
- A temporal filter is applied to select events that occurred within a specific date range.

## 3. **Data Filtering and Event Selection:**
- Events with Local Magnitude (ML) within a specified range and depth within a given interval are selected.
- Events with similar magnitudes to previous events are removed using a function based on a specified magnitude difference.
- A filter is applied to select only events with more than a specified number of monitoring stations.

## 4. **Statistical Regression:**
- Several regression analyses are performed to study the relationship between Local Magnitude (ML) and Moment Magnitude (Mw) using different regression methods:
  - **Ordinary Least Squares (OLS):** Ordinary Least Squares regression.
  - **Maximum Likelihood (MM):** Maximum Likelihood regression.
  - **Errors-in-Variables (EIV):** Regression that accounts for errors in the variables.
  - **Corrected Errors-in-Variables (EIVcorr):** EIV regression that accounts for errors in the event catalog.
- The results of each regression method are saved in separate tables.

## 5. **Merging Results and Saving:**
- The regression tables are combined into a single table containing the results from all regression methods.
- The final table is saved in both CSV and XLSX formats in the results folder.

## 6. **Graph Creation:**
- A graph is created to visualize the regression slope between Moment Magnitude (Mw) and Local Magnitude (ML) for each dataset.

## 7. **Repeating the Analysis for Other Periods and Datasets:**
- The filtering, regression, and result-saving process is repeated for other datasets from different time periods and regions.

## **Important Notes:**
- Input datasets should be placed in the `data` folder.
- After executing the `Main_code`, the results will be saved in the `results` folder.
