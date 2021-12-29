
######################################
# Data cleaning/exploration
######################################

# Convert to factors/date

df <- Housing_clean

summary(df)

df$Region <- as.factor(df$Region)

summary(df$Region)

df$Zoning <- as.factor(df$Zoning)

summary(df$Zoning)

df$Flood.Zone <- as.factor(df$Flood.Zone)

summary(df$Flood.Zone)

df$SoldDate <- as.Date(Housing_clean$SoldDate, '%Y-%m-%d')

summary(df$SoldDate)

df$ListDate <- as.Date(df$ListDate, '%Y-%m-%d')

summary(df$ListDate)

######################################
# Original Price
######################################

plot(df$Sold.Price, df$Original.Price)

# Identify outliers on original price

out <- boxplot.stats(df$Original.Price)$out

out_ind <- which(df$Original.Price %in% c(out))

out_ind

df[out_ind,]

# Outlier MLS 202115880, original price should be $1,200,000, not $120,000

df[282, 'Original.Price'] <- 1200000


# Outlier MLS 202104492, original price should be $1,000,000, not $2,400,000

df[509, 'Original.Price'] <- 1000000


# Outlier MLS 202104493, original price should be $1,400,000, not $2,400,000

df[511, 'Original.Price'] <- 1400000

plot(df$Original.Price, df$Sold.Price)

######################################
# Assessed Total
######################################

# Identify outliers on assessed total

plot(df$Assessed.Total, df$Sold.Price)


out <- boxplot.stats(df$Assessed.Total)$out

out_ind <- which(df$Assessed.Total %in% c(out))

out_ind

df[out_ind,]


# MLS 202112795 should be 704,600, not 7,046,000

df[342, 'Assessed.Total'] <- 704600

# MLS 202032570 should be 900,000, not 2,012,500

df[356, 'Assessed.Total'] <- 900000

# MLS 202109222 should be 1,256,000, not 125,600

df[423, 'Assessed.Total'] <- 1256000


# If Assessed Total = 1 or 2, make the original price

df[2, 'Assessed.Total'] <- df[2, 'Original.Price']

df[34, 'Assessed.Total'] <- df[34, 'Original.Price']

df[323, 'Assessed.Total'] <- df[323, 'Original.Price']

df[461, 'Assessed.Total'] <- df[461, 'Original.Price']

df[468, 'Assessed.Total'] <- df[468, 'Original.Price']

df[537, 'Assessed.Total'] <- df[537, 'Original.Price']

df[202, 'Assessed.Total'] <- df[202, 'Original.Price']

df[708, 'Assessed.Total'] <- df[708, 'Original.Price']

df[610, 'Assessed.Total'] <- df[610, 'Original.Price']


plot(df$Assessed.Total, df$Sold.Price)

######################################
# Living sq ft
######################################

plot(df$Living.Sq.Ft, df$Sold.Price)

out <- boxplot.stats(df$Living.Sq.Ft)$out

out_ind <- which(df$Living.Sq.Ft %in% c(out))

out_ind

df[out_ind,]

df[df['Living.Sq.Ft'] == 0,]
# MLS 202116772 land only, no house, remove as outlier.
df <- df[!(df$Living.Sq.Ft == 0),]

plot(df$Living.Sq.Ft, df$Sold.Price)

######################################
# Land sq ft
######################################

plot(df$Land.Sq.Ft, df$Sold.Price)

out <- boxplot.stats(df$Land.Sq.Ft)$out

out_ind <- which(df$Land.Sq.Ft %in% c(out))

out_ind

df[out_ind,]

df[df['Land.Sq.Ft'] > 800000,]
# Remove outliers with land sq ft greater than 800,000

df <- df[!(df$Land.Sq.Ft > 800000),]

plot(df$Land.Sq.Ft, df$Sold.Price)

df[df['Land.Sq.Ft'] > 15000,]
# Remove outliers with land sq ft greater than 800,000

df <- df[!(df$Land.Sq.Ft > 15000),]

plot(df$Land.Sq.Ft, df$Sold.Price)

# Fill missing stories variable values with mean
df$Stories[is.na(df$Stories)] <- median(df$Stories, na.rm=TRUE)

# Remove variables unknown at time of listing
# Sold ratio, original ratio, days, Land.1, Building, Assessed.Ratio,
# SoldDate, ListDate, price increase, price decrease, above original.

df2 <- df[-c(6,7,12,16,17,19,26,27,28,29,31)]

######################################
# Run initial OLS model on sold price
######################################

model <- lm(Sold.Price ~ ., data=df2)
summary(model)

# Create numeric dataset
dfNumeric <- df2[-c(4,14,15)]
summary(dfNumeric)

library(corrplot)
corrplot(cor(dfNumeric), order="AOE")

# Create test and training set

set.seed(123)

nrow(df2)   # returns 747
s = sample(1:747, 80)
scaledTrain = as.data.frame(scale(dfNumeric[s, ]))  # only the rows in "sample", but all the columns
scaledTest = as.data.frame(scale(dfNumeric[-s, ]))

housesTrain = df2[s,]
housesTest = df2[-s,]

# Model including all variables scaled
fullFit = lm(Sold.Price ~ ., data=scaledTrain)
summary(fullFit)  # Adjusted R-Squared = 0.8097, R^2=0.8651

# RMSE for OLS Training
rmseOLS = sqrt(mean(fullFit$residuals^2))
rmseOLS  # 0.365

# RMSE for OLS Testing
yHat_OLS = predict(fullFit, newdata=scaledTest)
residOLS = scaledTest$Sold.Price - yHat_OLS
rmseOLS_test = sqrt(mean(residOLS^2))
rmseOLS_test  # 0.557

# Fit model on unscaled data, including categorical variables
fullFitunscaled = lm(Sold.Price ~ ., data=housesTrain)
summary(fullFitunscaled)  # Adjusted R-Squared = 0.8362; .R^2 = 0.9026

# RMSE for OLS Training
rmseOLS = sqrt(mean(fullFitunscaled$residuals^2))
rmseOLS  # 58,194

# RMSE for OLS Testing
yHat_OLS = predict(fullFitunscaled, newdata=housesTest)
residOLS = housesTest$Sold.Price - yHat_OLS
rmseOLS_testunscaled = sqrt(mean(residOLS^2))
rmseOLS_testunscaled  # 1,146,128

######################################
# Automatic model building
######################################

library(leaps)
fit_all = regsubsets(Sold.Price ~ ., data=df2)
plot(fit_all, scale="adjr2")  # Orig.Price, Flood.ZoneZoneX, Assessed.Total, Photos
plot(fit_all, scale="Cp")     # Same as above
plot(fit_all, scale="bic")    # Same as above, next ones are beds, density apartment,
                              # More flood zones

df2auto <- df2[c('Sold.Price', 'Original.Price', 'Flood.Zone', 'Assessed.Total', 'Photos')]

set.seed(123)

nrow(df2auto)   # returns 747
s = sample(1:747, 80)

autoTrain = df2auto[s,]
autoTest = df2auto[-s,]

fitauto = lm(Sold.Price ~ ., data=df2auto)
summary(fitauto)  # R-Squared = 0.8056, ARS = 0.8027

# RMSE auto training 
rmseAutoTrain = sqrt(mean(fitauto$residuals^2))
rmseAutoTrain  # 86,112

# Now, let's see how it does on the test set!
yHat_OLS = predict(fitauto, newdata=autoTest)
residOLS = autoTest$Sold.Price - yHat_OLS
rmseAutoTest = sqrt(mean(residOLS^2))
rmseAutoTest  # 86,925

######################################
# Use cross validated LASSO
######################################

library(glmnet)

set.seed(123)

nrow(dfNumeric)   # returns 747
s = sample(1:747, 80)
lassoTrain = as.data.frame((dfNumeric[s, ]))  # only the rows in "sample", but all the columns
lassoTest = as.data.frame((dfNumeric[-s, ]))

xTrain = as.matrix(lassoTrain[,-c(4)])  # Only the x's
yTrain = as.matrix(lassoTrain$Sold.Price)

set.seed(123)
# Compute the cross-validated lasso fit
cvfit = cv.glmnet(xTrain, yTrain)
print(cvfit$lambda.min)  # 9252.868
print(cvfit$lambda.1se)  # 28,256.92
coef(cvfit, s="lambda.min")  # Photos, orig price, land sq ft, year, condition, pool, rem5yrs, basement
coef(cvfit, s="lambda.1se") # Photos, Orig Price

# Now, use it to predict
xTest = as.matrix(lassoTest[,-c(4)])
yTest = as.matrix(lassoTest$Sold.Price)
yPredict = predict(cvfit, newx=xTest, s="lambda.1se")

# Now compute the new RMSE 
rmseLasso_test = sqrt(mean((yTest - yPredict)^2))
rmseLasso_test  # 92,717 for lambda.min, 96,425 for lambda.1se

# Compare it to OLS
rmseOLS_testunscaled  # 1,146,128
rmseAutoTest  # 86,925

######################################
# Ridge Regression
######################################

library(glmnet)

lRange = seq(0, 10000000, 1000000)
fitRidge2 = glmnet(xTrain, yTrain, alpha=0, lambda=lRange)
plot(fitRidge2, xvar="lambda")

summary(fitRidge2)  
fitRidge2           

fitRidge3 = cv.glmnet(xTrain, yTrain, alpha=0, nfolds=7)
fitRidge3$lambda.min  # 16550
fitRidge3$lambda.1se  # 80476
plot(fitRidge3)

ridgePred = predict(fitRidge3, xTest, s="lambda.min")
rmseRidge = sqrt(mean((ridgePred - yTest)^2))
rmseRidge  # 106,907

# Compare to:
rmseLasso_test  # 92,717 for lambda.min, 96,425 for lambda.1se
rmseOLS_testunscaled  # 1,146,128
rmseAutoTest  # 86,925

# Calculate R^2 and compare to original
summary(fullFit)  # R^2 = 0.8651
fitRidge2 = glmnet(xTrain, yTrain, alpha=0, lambda=16550)
fitRidge2         # R^2 = 0.8542

######################################
# Elastic Net
######################################

lRange = seq(0, 100000, 10000)
fitElastic = glmnet(xTrain, yTrain, alpha=.5, lambda=lRange)

plot(fitElastic, xvar="lambda")

fitElastic

fitElastic = cv.glmnet(xTrain, yTrain, alpha=.5, nfolds=7)
fitElastic$lambda.min   # 13,998
fitElastic$lambda.1se   # 29,466

plot(fitElastic)

elasticPred = predict(fitElastic, xTest, s="lambda.1se")
rmseElastic = sqrt(mean((elasticPred - yTest)^2))
rmseElastic  # 93,585 for lambda.min, 94,843 for lambda.1se

# Compare to:
rmseRidge  # 106,907
rmseLasso_test  # 92,717 for lambda.min, 96,425 for lambda.1se
rmseOLS_testunscaled  # 1,146,128
rmseAutoTest  # 86,925

