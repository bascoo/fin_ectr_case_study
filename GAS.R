## install.packages("highfrequency")
library(highfrequency)
library(utils)
library(data.table)
library(R.matlab)
library(GAS)
library("parallel")

## Load Matlab Daily Returns, Realised Volatilty 
path <- system.file("mat-files", package = "R.matlab")
pathname <- file.path(path, "RV.mat")
RV <- readMat(pathname)
pathname <- file.path(path, "Daily_returns.mat")
Daily_returns <- readMat(pathname)


## LOAD DATA BY HAND
# File: CloseToOPen_RV.csv
# FIle: RK_OpenTOClose

################## Close To Open & Realised Volatitily #########################
## Univariate GAS (Only using Close To Open)
GASSpec = UniGASSpec(Dist = "std", ScalingType = "Identity",
                       GASPar = list(location = TRUE, scale = TRUE, 
                                     skewness = FALSE, shape = FALSE, shape2 = FALSE))

Roll_CTO = UniGASRoll(CloseToOpen_RV$CloseToOpen, GASSpec, ForecastLength = 500,
                  RefitEvery = 500)
plot(Roll,which = 2)

## Univariate GAS (Realised volatility)
GASSpec = UniGASSpec(Dist = "std", ScalingType = "Identity",
                     GASPar = list(location = TRUE, scale = TRUE, 
                                   skewness = FALSE, shape = FALSE, shape2 = FALSE))

Roll_RV = UniGASRoll(CloseToOpen_RV$CloseToOpen, GASSpec, ForecastLength = 500,
                  RefitEvery = 500)
plot(Roll,which = 2)


## Multivariate GAS (Realised Volatility & Close to Open)
MGASSpec = MultiGASSpec(Dist = "mvt", ScalingType = "Identity",
                        GASPar = list(location = TRUE, scale = TRUE,
                                      correlation = TRUE, shape = TRUE),
                        ScalarParameters = TRUE)

MRoll_RV_CTO = MultiGASRoll(CloseToOpen_RV,MGASSpec,ForecastLength = 500,
                     RefitEvery = 500)
plot(MRoll,which = 2)

write.csv(Roll@Forecast$PointForecast, file = "Roll.csv")
write.csv(MRoll@Forecast$PointForecast, file = "MRoll.csv")


################## Open To Close & Realized Kernel #########################
## Univariate GAS Open To Close
GASSpec = UniGASSpec(Dist = "std", ScalingType = "Identity",
                     GASPar = list(location = TRUE, scale = TRUE, 
                                   skewness = FALSE, shape = FALSE, shape2 = FALSE))

Roll_OTC = UniGASRoll(RK_OpenToClose$RK, GASSpec, ForecastLength = 1000,
                  RefitEvery = 100)
plot(Roll,which = 2)

## Univariate GAS Realized Kernel
GASSpec = UniGASSpec(Dist = "std", ScalingType = "Identity",
                     GASPar = list(location = TRUE, scale = TRUE, 
                                   skewness = FALSE, shape = FALSE, shape2 = FALSE))

Roll_OTC = UniGASRoll(RK_OpenToClose$RK, GASSpec, ForecastLength = 1000,
                  RefitEvery = 100)
plot(Roll,which = 2)

## Multivariate GAS Open To Close & Realized Kernel 
MGASSpec = MultiGASSpec(Dist = "mvt", ScalingType = "Identity",
                        GASPar = list(location = TRUE, scale = TRUE,
                                      correlation = FALSE, shape = FALSE),
                        ScalarParameters = TRUE)

MRoll_RK_OTC = MultiGASRoll(RK_OpenToClose,MGASSpec,ForecastLength = 300,
                     RefitEvery = 300)
plot(MRoll,which = 2)

write.csv(Roll@Forecast$PointForecast, file = "Roll_OTC_RK.csv")
write.csv(MRoll@Forecast$PointForecast, file = "MRoll_OTC_RK.csv")
