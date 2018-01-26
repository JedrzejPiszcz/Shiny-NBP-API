# rm(list=ls())     #czyści workspace
# wd<-"C:/GIT/R_wd/Shiny-NBP-API" #ustawić working directory
# if(getwd()!=wd){setwd(wd)}
# env_ZIPCMD<-"C:/Rtools/bin/zip"                           #nalezy ustawic sciezke do pliku zip w pakiecie rtools
# if(Sys.getenv("R_ZIPCMD")!=env_ZIPCMD){Sys.setenv(R_ZIPCMD = env_ZIPCMD)}

library(data.table)
library(RCurl)
library(tidyjson)
library(dplyr)
library(mailR)
library(tseries)
library(ggplot2)
library(forecast)
library(plotly)

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
} #rewrite to get just one or multiple selected currencies

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

num_cols<-c("currency.mid", "currency.ask", "currency.bid")

Result[,num_cols] = apply(Result[,num_cols], 2, function(x) as.numeric(as.character(x)))

return(Result)
}

