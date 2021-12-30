# Honolulu Housing Price Prediction Project Overview
* Created a model that estimates sold prices for Honolulu houses (RMSE ~ $87,000) to help home buyers estimate a competitive bid offer in R.
* Custom built a web scraper using Python and Selenium for a local real estate website.
* Cleaned 700+ observations of Honolulu houses sold within the past year using Python (Pandas, Numpy) and R.
* Optimized Linear, Ridge, Lasso, and Elastic Net Regressors to identify model with best predictive validity.

## Code and Resources Used
**Packages:** pandas, numpy, selenium, re, datetime, csv, leaps, glmnet, corrplot
**Scraper Github:** https://github.com/PlayingNumbers/ds_salary_proj/blob/master/glassdoor_scraper.py

## Web Scraping
Created a scraper than scrapes listings from the similar listings page (maximum of 100 per page), then clicks on last listing to find new similar listings page. Scraper identifies if new listing was already collected, in the correct region, and sold within given parameter (e.g., last 12 months).

## Data Cleaning
Used file downloaded directly from website of data obtained with search parameters:
* Sold within past year
* Minimum sold price = $800,000
* Maximum sold price = $1,500,000

Returned 747 rows and cleaned data by:
* Creating binary variables of CPR, remodeled within 5 years, pool, view, easements, level topography, basement, split level
* Parsing bath variable to create full and half bath columns
* Coverted house condition into ordinal variable, taking average value when more than one condition provided
* Parsed number of parking stalls and filled missing values with the median value (2)
* Parsed number of stories and filled missing values with the median value (2)
* Identified and corrected outliers for independent variables (original price, assessed total, living sq. ft., land sq. ft.)

## Model Building
I split the data into training and testing sets with a test size of 20%.
I tried five different models:
* **Original Least Squared Regression** - Baseline for the model
* **Automatic Model** - To reduce dimensionality and improve predictive validity
* **Ridge** - To reduce variance and improve predictive validity
* **Lasso** - To reduce dimensionality and improve predictive validity
* **Elastic Net** - To examine the mix of Ridge and Lasso

## Model Performance
The Automatic Model builder had the lowest root mean squared error (RMSE) on the test set.
Using the "adjr2", 'Cp", and "bic" scales, the automatic model builder consistently selected:
* Original Price
* FloodZone
* Assessed Total
* Number of Photos

The RMSE for each model are as follows:
* **Automatic Model:** 86,925
* **Ridge:** 106,907
* **Lasso:** 92,717
* **Elastic Net:** 93,585



