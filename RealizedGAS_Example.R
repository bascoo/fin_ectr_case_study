## Fit Realized GARCH
library(rugarch)
require(xts)
data(spyreal)
spec = ugarchspec(mean.model = list(armaOrder = c(0, 0), include.mean = FALSE), variance.model = list(model = 'realGARCH', garchOrder = c(2, 1)))
fit = ugarchfit(spec, spyreal[, 1] * 100, solver = 'hybrid', realizedVol = spyreal[,2] * 100)

## News Impact Curve
ni = newsimpact(fit, z = seq(-2, 2, length.out = 100))
plot(ni$zx, (ni$zy), ylab = ni$yexpr, xlab = ni$xexpr, type = 'l', main = 'News Impact realGARCH')
abline(v = 0)
abline(h = 0)
grid()

## Forecasting
fit = ugarchfit(spec, spyreal[, 1] * 100, out.sample = 25, solver = 'hybrid', realizedVol = spyreal[, 2] * 100)
specf = spec
setfixed(specf)<- as.list(coef(fit))
filt = ugarchfilter(specf, data = spyreal[, 1] * 100, n.old = nrow(spyreal) - 25, realizedVol = spyreal[, 2] * 100)
forc1 = ugarchforecast(fit, n.ahead = 1, n.roll = 25)
# forecast from spec
forc2 = ugarchforecast(specf, n.ahead = 1, n.roll = 25, data = spyreal[, 1] * 100, out.sample = 25, realizedVol = spyreal[, 2] * 100)
filts = tail(sigma(filt), 25)
colnames(filts) = 'filter'
forcs1 = xts(sigma(forc1)[1, ], move(as.Date(names(sigma(forc1)[1, ])), by = 1))
forcs2 = xts(sigma(forc2)[1, ], move(as.Date(names(sigma(forc2)[1, ])), by = 1))
colnames(forcs1) = 'fit2forecast'
colnames(forcs2) = 'spec2forecast'
ftest = cbind(filts, forcs1, forcs2)
# last forecast is completely out of sample, so not available from the
# filter method (which filters given T-1)
print(round(ftest, 5))

## long-horizon forecast
set.seed(55)
forc3 = ugarchforecast(fit, n.ahead = 400, n.sim = 5000)
plot(sigma(forc3), type = 'l', main = 'realGARCH long-run forecast')
abline(h = sqrt(uncvariance(fit)), col = 2)
legend('topright', c('long-run forecast', 'unconditional value'), col = 1:2, lty = c(1, 1), bty = 'n')


## Extract forecast density from forecasted object.
set.seed(55)
forc4 = ugarchforecast(fit, n.ahead = 25, n.sim = 10000)
# dim(forc4@forecast$sigmaDF)
sigmaDF = forc4@forecast$sigmaDF
meansig = sqrt(exp(rowMeans(log(sigmaDF[, , 1]^2))))
boxplot(t(sigmaDF[, , 1]), main = '25-ahead volatility forecast (realGARCH)', col = 'orange')
points(as.numeric(meansig), col = 'green')
# note that for the 1-ahead there is no uncertainty 
# (unless we were doing this Bayes-style so that parameter uncertainty would have an impact).


## Demonstration Simulation
# There are 2 ways to simulate from GARCH models in the rugarch package: 
# either directly from an estimated object (uGARCHfit class) or from a GARCH spec (uGARCHspec with fixed parameters), 
# similarly to the ugarchforecast method. However, instead of having a single dispatch method, 
# there is ugarchsim (for the uGARCHfit class) and ugarchpath (for the uGARCHspec class)
spec = ugarchspec(mean.model = list(armaOrder = c(1, 1), include.mean = TRUE), variance.model = list(model = 'realGARCH', garchOrder = c(1, 1)))
fit = ugarchfit(spec, spyreal[, 1] * 100, out.sample = 25, solver = 'hybrid', realizedVol = spyreal[, 2] * 100)
specf = spec
setfixed(specf)<- as.list(coef(fit))
T = nrow(spyreal) - 25
sim1 = ugarchsim(fit, n.sim = 1000, m.sim = 1, n.start = 0, startMethod = 'sample', rseed = 12)
sim2 = ugarchsim(fit, n.sim = 1000, m.sim = 1, n.start = 0, startMethod = 'sample', rseed = 12, 
                 prereturns = as.numeric(tail(spyreal[1:T, 1] * 100, 1)), presigma = as.numeric(tail(sigma(fit), 1)), 
                 preresiduals = as.numeric(tail(residuals(fit), 1)), prerealized = as.numeric(tail(spyreal[1:T, 2] * 100, 1)))
sim3 = ugarchpath(specf, n.sim = 1000, m.sim = 1, n.start = 0, rseed = 12, 
                  prereturns = as.numeric(tail(spyreal[1:T, 1] * 100, 1)), presigma = as.numeric(tail(sigma(fit), 1)), 
                  preresiduals = as.numeric(tail(residuals(fit), 1)), prerealized = as.numeric(tail(spyreal[1:T, 2] * 100, 1)))
print(cbind(head(sigma(sim1)), head(sigma(sim2)), head(sigma(sim3))))

# Application: Rolling Forecasts and Value at Risk
library(parallel)
cl = makePSOCKcluster(5)
spec1 = ugarchspec(mean.model = list(armaOrder = c(1, 1), include.mean = TRUE), variance.model = list(model = 'realGARCH', garchOrder = c(1, 1)))
spec2 = ugarchspec(mean.model = list(armaOrder = c(1, 1), include.mean = TRUE), variance.model = list(model = 'eGARCH', garchOrder = c(1, 1)))
roll1 = ugarchroll(spec1, spyreal[, 1] * 100, forecast.length = 500, solver = 'hybrid', refit.every = 25, refit.window = 'recursive', realizedVol = spyreal[, 2] * 100, cluster = cl)
roll2 = ugarchroll(spec2, spyreal[, 1] * 100, forecast.length = 500, refit.every = 25, refit.window = 'recursive', cluster = cl)
report(roll1) 
report(roll2)
plot(as.xts(as.data.frame(roll1)[, 'Sigma', drop = FALSE]), main = 'realGARCH vs eGARCH\n(out-of-sample volatility forecast)',  auto.grid = FALSE, minor.ticks = FALSE)
lines(as.xts(as.data.frame(roll2)[, 'Sigma', drop = FALSE]), col = 2)
legend('topleft', c('realGARCH', 'eGARCH'), col = 1:2, lty = c(1, 1), bty = 'n')
grid()











