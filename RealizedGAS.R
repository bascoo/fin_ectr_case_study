## Fit Realized GARCH
library(rugarch)
require(xts)
data(spyreal)
spec = ugarchspec(mean.model = list(armaOrder = c(0, 0), include.mean = FALSE), variance.model = list(model = 'realGARCH', garchOrder = c(2, 1)))
fit = ugarchfit(spec, spyreal[, 1] * 100, solver = 'hybrid', realizedVol = spyreal[,2] * 100)


ni = newsimpact(fit, z = seq(-2, 2, length.out = 100))
plot(ni$zx, (ni$zy), ylab = ni$yexpr, xlab = ni$xexpr, type = 'l', main = 'News Impact realGARCH')
abline(v = 0)
abline(h = 0)
grid()
