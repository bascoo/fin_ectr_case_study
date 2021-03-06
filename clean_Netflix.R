setwd("/Users/sjoerdvisser/Documents/VU/Fin_ectr_case/GM_data")


#################################################################################################################################
########################        Functions                ########################################################################
#################################################################################################################################
getDateTime = function(x){
  date = x[2]
  time = x[3]
  
  year = substr(date, 1, 4)
  month = substr(date, 5, 6)
  day = substr(date, 7, 8)
  date = paste(year, month, day, sep="-")
  paste(date, time, sep = " ")
}

getTimestamp = function(x){
  as.POSIXct(strptime(x['DATETIME'], "%Y-%m-%d %H:%M:%S"))
}

getPosix = function(x){
  as.POSIXct(strptime(x['DATETIME'], "%Y-%m-%d %H:%M:%S"), format="%m/%d/%Y %H:%M")
  #as.POSIXct(as.numeric(x['TIMESTAMP']),origin="1970-01-01", format="%m/%d/%Y %H:%M" )
}


cleanData = function(df){
  
  df = df[!df$PRICE==0,] #P2
  df = df[df$EX == 'N', ] #P3
  df = df[df$CORR==0,] #T1
  df = df[df$COND==' ' | df$COND==' ' | df$COND=='' | df$COND =='E' | df$COND =='F' , ] #T2
  
  df$DATE = toString(test2$DATE)
  df$DATETIME = NA
  df$TIMESTAMP = NA
  start.time <- Sys.time()
  df$DATETIME = apply(df, 1, getDateTime)
  df$TIMESTAMP = apply(df, 1, getTimestamp)
  end.time <- Sys.time()
  time.taken <- end.time - start.time
  time.taken
  
  # T3. 
  # T4
  
  return(df)
}
  
  

#################################################################################################################################
#################################################################################################################################
#################################################################################################################################



b = d2007

#hier nog for loop van maken
d2007 = read.csv('2007.csv', header = TRUE, sep = ',')
d2008 = read.csv('2008.csv', header = TRUE, sep = ',')
d2009 = read.csv('2009.csv', header = TRUE, sep = ',')
d2010 = read.csv('2010.csv', header = TRUE, sep = ',')
d2011 = read.csv('2011.csv', header = TRUE, sep = ',')
d2012 = read.csv('2012.csv', header = TRUE, sep = ',')
d2013 = read.csv('2013.csv', header = TRUE, sep = ',')
d2014 = read.csv('2014.csv', header = TRUE, sep = ',')

d2007c = cleanData(d2007)
d2008c = cleanData(d2008)
d2009c = cleanData(d2009)
d2010c = cleanData(d2010)
d2011c = cleanData(d2011)
d2012c = cleanData(d2012)
d2013c = cleanData(d2013)
d2014c = cleanData(d2014)

d = do.call("rbind", list(d2007c, d2008c, d2009c, d2010c, d2011c, d2012c, d2013c, d2014c))
head(d, n=10)
tail(d, n=10)

datasetFiltered = d
d = datasetFiltered

rownames(d) <- NULL
write.csv(d, file = "data_cleaned_trades.csv")

# P1. Delete entries with a time stamp outside the 9:30 am–4 pm window
#1 string of both columns

# P2. Delete entries with a bid, ask or transaction price equal to zero.
d2007 = d2007[!d2007$PRICE==0,]

# P3.  Retain entries originating from a single exchange (NYSE in our application)
d2007 = d2007[d2007$EX == 'N', ]

#T1. Delete entries with corrected trades. (Trades with aCorrection Indicator,CORR!=0).
d2007 = d2007[d2007$CORR==0,]
#T2. Delete entries with abnormal Sale Condition. (Trades where COND has a letter code, except for ‘E’ and ‘F’). See the TAQ 3 User’s Guide for additional details about sale
#conditions.
summary(d2007$COND)
d2007 = d2007[d2007$COND==' ' | d2007$COND =='E' | d2007$COND =='F', ]
summary(d2007$COND) #whitespace wordt nu ook verwijderd, dit mag niet

# T3.  If multiple transactions have the same time stamp, use the median price.
#done at T1
d2007$DATE = toString(test2$DATE)
d2007$DATETIME = NA
d2007$TIMESTAMP = NA

backup = d2007
start.time <- Sys.time()
d2007$DATETIME = apply(d2007, 1, getDateTime)
d2007$TIMESTAMP = apply(d2007, 1, getTimestamp)
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

#https://stackoverflow.com/questions/22203493/aggregate-1-minute-data-into-5-minute-average-data

#https://stackoverflow.com/questions/42673808/5-minute-intervals-of-my-data-in-r
library(data.table)
setDT(df1)[, lapply(.SD, mean), .(grp = cut(timestamp, breaks = "5 min"))]

#https://stats.stackexchange.com/questions/7268/how-to-aggregate-by-minute-data-for-a-week-into-hourly-means






# T4.  Delete entries with prices that are above the ‘ask’ plus the bid–ask spread. 
#Similar forentries with prices below the ‘bid’ minus the bid–ask spread.







#################################################################################################################################
#################################################################################################################################











test2 = d2007[1:100,]


test2$DATE = toString(test2$DATE)
test2$DATETIME = NA
test2$TIMESTAMP = NA
test2$POSIX = NA

test2$DATETIME = apply(test2, 1, getDateTime)
test2$TIMESTAMP = apply(test2, 1, getTimestamp)
test2$POSIX = apply(test2, 1, getPosix)

cut(test2$POSIX, breaks="5 min")

cut(test2$TIMESTAMP, breaks=5)

means <- aggregate(df["Concentration"], 
                   list(fiveMin=cut(df$DeviceTime, "5 mins")),
                   mean)

as.Date(1167813007/1000, origin="1970-01-01")

typeof(test2$TIMESTAMP)

#test
as.Date(as.POSIXct(1167813007, origin="1970-01-01"))
as.POSIXlt.numeric(as.numeric(1167813007),origin="1970-01-01")





typeof(d2007$TIME)
test[test$TIME>9:30:00,]
summary(test$TIME)

toString(test$TIME)
typeof(toString(test$TIME[1]))
typeof(test$DATE)





#2 to timestamp
#3 



test[1,'PRICE'] = 0
test = test[!test$PRICE==0, ]


nrow(d2007) #9515988
d2007 =d2007[!d2007$PRICE==0,]
nrow(d2007b) #9515988

 

 

 
 
 
 
 df <- read.table(header=TRUE, sep=",", stringsAsFactors=FALSE, text="
DeviceTime,Concentration
6/20/2013 11:13,1
6/20/2013 11:14,1
6/20/2013 11:15,2
6/20/2013 11:16,2
6/20/2013 11:17,2
6/20/2013 11:18,2
6/20/2013 11:19,2
6/20/2013 11:20,3
6/20/2013 11:21,3
6/20/2013 11:22,3
6/20/2013 11:23,3
6/20/2013 11:24,3
6/20/2013 11:25,4")
 df$DeviceTime <- as.POSIXct(df$DeviceTime, format="%m/%d/%Y %H:%M")
 df$DeviceTime
 
 test2$DATETIME
 cut(as.POSIXlt.numeric(as.numeric(test2TIMESTAMP),origin="1970-01-01"), breaks="5 min")

cut(df$DeviceTime, breaks="5 min")
 
 
 
 
 
