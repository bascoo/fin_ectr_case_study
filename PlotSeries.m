function [ts1, ts2, ts3] = PlotSeries(vp_mle, vinput, vy, cT)
ilinkfunction=vinput(2);
[dloglik, vf, vscore, vscaledsc, vfunc] = LogLikelihoodGasVolaUniv(vp_mle, vinput, vy);
if ilinkfunction == 2 %SIGMA
    vfplot = sqrt(vf);
else
    vfplot = sqrt(exp(vf));
end

subplot(3,1,1)
ts1 = timeseries(vfplot,1:cT);
ts1.Name = 'Estimated volatility';
ts1.TimeInfo.Units = 'weeks';
ts1.TimeInfo.StartDate = '03-Jan-2007'; % Set start date.
ts1.TimeInfo.Format = 'mm dd, yy';   % Set format for display on x-axis.
ts1.Time=ts1.Time-ts1.Time(1);       % Express time relative to the start date.
plot(ts1,'-r')
hold on
ts4 = timeseries(vy,1:cT);
ts4.Name = 'Returns';
ts4.TimeInfo.Units = 'weeks';
ts4.TimeInfo.StartDate = '03-Jan-2007'; 
ts4.TimeInfo.Format = 'dd-mm-yy';   
ts4.Time=ts4.Time-ts4.Time(1);       
plot(ts4)
title('Continuously compounded return and estimated volatility')

subplot(3,1,2)
ts2 = timeseries(vscore,1:cT);
ts2.Name = 'Score';
ts2.TimeInfo.Units = 'weeks';
ts2.TimeInfo.StartDate = '03-Jan-2007'; 
ts2.TimeInfo.Format = 'dd-mm-yy';   
ts2.Time=ts2.Time-ts2.Time(1);      
plot(ts2)

subplot(3,1,3)
ts3 = timeseries(vscaledsc,1:cT);
ts3.Name = 'Scaled score';
ts3.TimeInfo.Units = 'weeks';
ts3.TimeInfo.StartDate = '03-Jan-2007'; 
ts3.TimeInfo.Format = 'dd-mm-yy';  
ts3.Time=ts3.Time-ts3.Time(1);      
plot(ts3)

end