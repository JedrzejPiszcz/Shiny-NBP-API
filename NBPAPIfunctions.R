


library(data.table)
library(RCurl)
library(tidyjson)
library(dplyr)
library(mailR)
library(tseries)
library(ggplot2)
library(forecast)

getVaildateDates<-function(startDate, endDate){}

getDataFromNBPAPI<-function(table, start_date, end_date){
  
tryCatch({
    
    
    fileURL <- paste0("http://api.nbp.pl/api/exchangerates/tables/", table, "/", start_date, "/", end_date, "/?format=json")
    
    xData <- getURL(fileURL)
    
    json_file <- xData
    
    if(table=="A" || table =="B"){
      
      json_items <-json_file %>%
        gather_array %>%
        
        spread_values(table = jstring("table"),
                      number = jstring("no"),
                      date = jstring("effectiveDate")
        ) %>%
        
        
        
        enter_object("rates") %>% gather_array %>%   
        
        spread_values(currency.name = jstring("currency"),
                      currency.code  = jstring("code"),
                      currency.mid  = jstring("mid")
        ) %>%  
        
        select(table, number, date, currency.name, currency.code, currency.mid)
    }else if(table=="C") {
      
      
      json_items <-json_file %>%
        gather_array %>%
        
        spread_values(table = jstring("table"),
                      number = jstring("no"),
                      date = jstring("effectiveDate"),
                      trading_date = jstring("tradingDate")
        ) %>%
        
        
        
        enter_object("rates") %>% gather_array %>%   
        
        spread_values(currency.name = jstring("currency"),
                      currency.code  = jstring("code"),
                      currency.ask  = jstring("ask"),
                      currency.bid  = jstring("bid")
        ) %>%  
        
        select(table, number, date, trading_date, currency.name, currency.code, currency.ask, currency.bid)
      
      
    }
    
    return (json_items)
    
  },
  
  error=function(e) {
    
    warning(paste("Error"))
    
    error_report<-TRUE
    
    return(NA)
  }
  )
}

getDataFromDateRange<-function(validStartDate, validEndDate){

Result<-NULL
tables<-c("A", "B", "C")

for(i in 1:length(tables))
{
  
  start_date <-validStartDate
  end_date <- start_date
  
  while(end_date<validEndDate)
  {
    start_date<-end_date
    end_date<-end_date+90
    
    if(end_date>validEndDate){end_date<-validEndDate}
    
    Result<-bind_rows(list(Result, 
                           getDataFromNBPAPI(tables[i], paste0(start_date), paste0(end_date))
                           )
                      ) 
  }
  
}

Result<-as.data.frame(Result)



return(Result)
}

finalResult<-getDataFromDateRange(validStartDate = validStartDate, validEndDate = validEndDate)

finalResult$nameAndCode<- paste0(finalResult$currency.code, " | ", finalResult$currency.name)
Currencies<-finalResult[!duplicated(finalResult$currency.code), c("currency.code", "currency.name", "nameAndCode")]
Currencies<-Currencies[order(Currencies$nameAndCode),]
