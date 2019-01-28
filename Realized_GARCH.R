netflix_dates = read.csv2("Documents/Case Study/dates.csv",header=T)
names(netflix_dates) = "DATES"

netflix_oc = read.csv2("Documents/Case Study/daily_return_opentoclose.csv",header=F)
names(netflix_oc) = "NFLX_OC"

netflix_rk = read.csv2("Documents/Case Study/realized_kernel.csv",header=F)
names(netflix_rk) = "NFLX_RK"

netflix_oc = apply(netflix_oc, 1, getToInt)
netflix_rk = apply(netflix_rk, 1, getToInt)

nflx = cbind(netflix_oc, netflix_rk)
nflx_xts = xts(nflx, order.by = as.POSIXct(netflix_dates$DATES), format="%Y%m%d")

getToInt =  function(df){
  as.double(df[1])
}

spec = ugarchspec(mean.model = list(armaOrder = c(0, 0), include.mean = FALSE), variance.model = list(model = 'realGARCH', garchOrder = c(1, 1)))
fit = ugarchfit(spec, nflx_xts[, 1] * 100, solver = 'hybrid', realizedVol = nflx_xts[,2] * 100)

cf = coef(fit)
se = fit@fit$matcoef[, 2]
names(se) = names(cf)
