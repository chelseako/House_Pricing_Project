# Honolulu Housing Price Prediction Project Overview
* Created a model that estimates sold prices for Honolulu houses (RMSE ~ $87,000) to help home buyers estimate a competitive bid offer.
* Custom built a web scraper using Python and Selenium for a local real estate website.
* Cleaned 700+ observations of Honolulu houses sold within the past year using Python (Pandas, Numpy) and R.
* Optimized Linear, Ridge, Lasso, and Elastic Net Regressors to identify model with best predictive validity.

## Code and Resources Used
**Packages:** pandas, numpy, selenium, re, datetime, csv, leaps, glmnet, corrplot
**Scraper Github:** https://github.com/PlayingNumbers/ds_salary_proj/blob/master/glassdoor_scraper.py

## Web Scraping
Created a scraper than scrapes listings from the similar listings page (maximum of 100 per page), then clicks on last listing to find new similar listings page. Scraper identifies if new listing was already collected, in the correct region, and sold within given parameter (e.g., last 12 months).

The website allowed search parameters and displayed a table that could be downloaded directly as an Excel file. I used this excel file for time efficiency. To decrease variance and improve predictive validity, I used the following search parameters:
* Sold within past year
* Minimum sold price = $800,000
* Maximum sold price = $1,500,000

## Data Cleaning
Cleaned 747 rows and 68 columns:
* Removed index/irrelevant columns
* Examined outliers and manually corrected erroneously entered values, removed irrelevant outliers (e.g., land only)
* Created binary variables of CPR, remodeled within 5 years, pool, view, easements, level topography, basement, split level
* Parsed bath variable to create full and half bath columns
* Converted house condition into ordinal variable, took average value when more than one condition was provided
* Parsed number of parking stalls and filled missing values with the median value (2)
* Parsed number of stories and filled missing values with the median value (2)

## Model Building
I split the data into training and testing sets with a test size of 20%.
I tried five different models:
* **Original Least Squares (OLS) Regression** - Baseline for the model
* **Regsubsets OLS** - To reduce dimensionality and improve predictive validity
* **Ridge** - To reduce variance and improve predictive validity
* **Lasso** - To reduce dimensionality and improve predictive validity
* **Elastic Net** - To examine the mix of Ridge and Lasso

## Model Performance
The OLS model built using the regsubsets automatic model selection function had the lowest root mean squared error (RMSE) on the test set. The regsubsets function, using the "adjr2", "Cp", and "bic" scales, consistently selected the following four variables:
* Original Price
* FloodZone
* Assessed Total
* Number of Photos

The RMSEs for each model are as follows:
* **Regsubsets OLS:** 86,925
* **Ridge:** 106,907
* **Lasso:** 92,717
* **Elastic Net:** 93,585

