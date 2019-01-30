## install.packages("highfrequency")
library(highfrequency)
library(utils)
library(data.table)
library(R.matlab)
library(GAS)
library(parallel)
library(forecast)


## LOAD DATA BY HAND
RK_OpenToClose <- read.csv("RK_OpenToClose.csv", header = TRUE)
CloseToOpen_RV <- read.csv("CloseToOpen_RV.csv", header = TRUE)


## Variables
Nyear= 513
Ntotal = length(CloseToOpen_RV$RV)

## Function To Remove Outliers
remove_outliers <- function(x, na.rm = TRUE, ...) {
  qnt <- quantile(x, probs=c(.005, .995), na.rm = na.rm, ...)
  H <- 1.5 * IQR(x, na.rm = na.rm)
  y <- x
  y[x < (qnt[1] - H)] <- NA
  y[x > (qnt[2] + H)] <- NA
  y
}

## Trim Data Close To Open 
CTO <- remove_outliers(CloseToOpen_RV$CloseToOpen)
CTO[is.na(CTO)] <- 0
# CTO <- CTO - mean(CTO)
#CTO <- CloseToOpen_RV$CloseToOpen #-mean(CloseToOpen_RV$CloseToOpen)

## Trim Data Open To Close 
OTC <- remove_outliers(RK_OpenToClose$OpenToClose)
OTC[is.na(OTC)] <- 0
#OTC <- OTC - mean(OTC)

################## Close To Open #########################
#### Univariate GAS / Normal-GAS
GASSpec = UniGASSpec(Dist = "norm", ScalingType = "Identity",
                     GASPar = list(location = TRUE, scale = TRUE, shape = TRUE,skewness = TRUE))

Roll_CTO_N = UniGASRoll(CTO, GASSpec, ForecastLength = Nyear,
                  RefitEvery = Nyear)

# Fit 
FIT_CTO_N <- UniGASFit(GASSpec, CTO[1:(Ntotal-Nyear)])

#### Univariate GAS / T-GAS
GASSpec = UniGASSpec(Dist = "std", ScalingType = "Identity",
                     GASPar = list(location = TRUE, scale = TRUE, 
                                   shape = TRUE))

Roll_CTO_T = UniGASRoll(CTO, GASSpec, ForecastLength = Nyear,
                       RefitEvery = Nyear)
# Fit 
FIT_CTO_T <- UniGASFit(GASSpec, CTO[1:(Ntotal-Nyear)])

### Univariate GAS / Skew-Student-t-GAS
GASSpec = UniGASSpec(Dist = "sstd", ScalingType = "Inv",
                     GASPar = list(location = TRUE, scale = TRUE, 
                                   shape = TRUE, skewness = TRUE))

Roll_CTO_ST = UniGASRoll(CTO, GASSpec, ForecastLength = Nyear ,
                       RefitEvery = Nyear)

## FIT 
FIT_CTO_ST <- UniGASFit(GASSpec, CTO[1:(Ntotal-Nyear)])

################## Open To Close #########################
#### Univariate GAS / Normal-GAS
GASSpec = UniGASSpec(Dist = "norm", ScalingType = "Identity",
                     GASPar = list(location = TRUE, scale = TRUE, shape = FALSE,skewness = FALSE))

Roll_OTC_N = UniGASRoll(OTC, GASSpec, ForecastLength = Nyear,
                        RefitEvery = Nyear)

# Fit 
FIT_OTC_N <- UniGASFit(GASSpec, OTC[1:(Ntotal-Nyear)])

#### Univariate GAS / T-GAS
GASSpec = UniGASSpec(Dist = "std", ScalingType = "Identity",
                     GASPar = list(location = TRUE, scale = TRUE, 
                                   shape = TRUE))

Roll_OTC_T = UniGASRoll(OTC, GASSpec, ForecastLength = Nyear,
                        RefitEvery = Nyear)
# Fit 
FIT_OTC_T <- UniGASFit(GASSpec, OTC[1:(Ntotal-Nyear)])

### Univariate GAS / Skew-Student-t-GAS
GASSpec = UniGASSpec(Dist = "sstd", ScalingType = "Inv",
                     GASPar = list(location = TRUE, scale = TRUE, 
                                   shape = TRUE, skewness = TRUE))

Roll_OTC_ST = UniGASRoll(OTC, GASSpec, ForecastLength = Nyear,
                         RefitEvery = Nyear)

## FIT 
FIT_OTC_ST <- UniGASFit(GASSpec, OTC[1:(Ntotal-Nyear)])


##### Predicted Volatility vs Kernel

ts.plot(cbind(Roll_CTO_N@Forecast$Moments[,2],RK_OpenToClose$RK[(Ntotal-Nyear+1):Ntotal]),col = c("red", "blue"))
ts.plot(cbind(Roll_CTO_T@Forecast$Moments[,2],RK_OpenToClose$RK[(Ntotal-Nyear+1):Ntotal]),col = c("red", "blue"))
ts.plot(cbind(Roll_CTO_ST@Forecast$Moments[,2],RK_OpenToClose$RK[(Ntotal-Nyear+1):Ntotal]),col = c("red", "blue"))
ts.plot(cbind(Roll_OTC_N@Forecast$Moments[,2],RK_OpenToClose$RK[(Ntotal-Nyear+1):Ntotal]),col = c("red", "blue"))
ts.plot(cbind(Roll_OTC_T@Forecast$Moments[,2],RK_OpenToClose$RK[(Ntotal-Nyear+1):Ntotal]),col = c("red", "blue"))
ts.plot(cbind(Roll_OTC_ST@Forecast$Moments[,2],RK_OpenToClose$RK[(Ntotal-Nyear+1):Ntotal]),col = c("red", "blue"))


## Save Data
write.csv(Roll_RV_N@Forecast$PointForecast, file = "Roll_RV_N_CTO.csv")
write.csv(Roll_RV_T@Forecast$PointForecast, file = "Roll_RV_T_CTO.csv")
write.csv(Roll_RV_ST@Forecast$PointForecast, file = "Roll_RV_ST_CTO.csv")
write.csv(Roll_RV_N@Forecast$PointForecast, file = "Roll_RK_N_OTC.csv")
write.csv(Roll_RK_T@Forecast$PointForecast, file = "Roll_RK_T_OTC.csv")
write.csv(Roll_RK_BETA@Forecast$PointForecast, file = "Roll_RK_BETA_OTC.csv")









