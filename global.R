library(nycflights13)
library(dplyr)
options(scipen = 999)

source("./NBPAPIfunctions.R")

validStartDate<-as.Date("2017-01-01")
validEndDate<-as.Date("2017-12-01")

finalResult<-getDataFromDateRange(validStartDate = validStartDate, validEndDate = validEndDate)
finalResult$date<-as.Date(finalResult$date)
finalResult$nameAndCode<- paste0(finalResult$currency.code, " | ", finalResult$currency.name)

Currencies<-unique(finalResult[c("currency.name", "currency.code", "nameAndCode", "table")])
Currencies<-Currencies[order(Currencies$nameAndCode),]

Tables<-finalResult[!duplicated(finalResult$table), c("table")]
