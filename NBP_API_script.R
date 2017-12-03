rm(list=ls())     #czy≈õci workspace
wd<-"C:/JPiszcz/Jedrzej/R_test" #ustawiƒá working directory
if(getwd()!=wd){setwd(wd)}
env_ZIPCMD<-"C:/Rtools/bin/zip"                           #nalezy ustawic sciezke do pliku zip w pakiecie rtools
if(Sys.getenv("R_ZIPCMD")!=env_ZIPCMD){Sys.setenv(R_ZIPCMD = env_ZIPCMD)}      

library(data.table)
library(RCurl)
library(tidyjson)
library(dplyr)
library(mailR)
library(tseries)
library(ggplot2)
library(forecast)

#DOPISA∆ TRYCATCH

error_report<-FALSE
send_mail<-function(text){
  
  
  sender <- "jedrzejpiszcz@gmail.com"
  recipients <- c("odbiorcy@server1.internal")
  send.mail(from = sender,
            to = recipients,
            subject = paste0("NBP_exchange_rates_report_", as.character(Sys.Date()) ),
            body = text,
            smtp = list(host.name = "smtp.gmail.com", port = 465, 
                        user.name = "jedrzejpiszcz@gmail.com",            
                        passwd = "v3rys3cr3tP@ssw0rD", ssl = TRUE),
            authenticate = TRUE,
            send = TRUE)
  
}

get_one_month_data_from_NBP_API<-function(table, start_date, end_date){

error_text <- tryCatch({
  

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



Result<-NULL
tables<-c("A", "B", "C")


for(i in 1:3)
{

    end_date<-as.Date(paste0(year(Sys.Date())-1, "-12-31"))

    while(end_date<Sys.Date())
    {
       start_date<-end_date+1
       end_date<-end_date+90
  
       if(end_date>Sys.Date()){end_date<-Sys.Date()}
        
       
       
       Result<-bind_rows(list(Result, get_one_month_data_from_NBP_API(tables[i], paste0(start_date), paste0(end_date))))
    }

}

Result<-as.data.frame(Result)

num_cols<-c("currency.mid", "currency.ask", "currency.bid")

Result[,num_cols] = apply(Result[,num_cols], 2, function(x) as.numeric(as.character(x)))

write.csv2(Result, file = paste0("NBP_exchange_rates_", as.character(Sys.Date()), ".csv"))


#PLOTTING & FORECASTING
#https://www.datascience.com/blog/introduction-to-forecasting-with-arima-in-r-learn-data-science-tutorials
Result$date<-as.Date(Result$date)
#y<-Result[which((Result$currency.code == "USD" | Result$currency.code == "EUR")& Result$table == "A"),]
y<-Result[which((Result$currency.code == "USD")& Result$table == "A"),]

ggplot(y, aes(x = date, y = currency.mid, colour = currency.code)) + 
      geom_line(alpha=.9, size =1) + 
      scale_x_date("month") + 
      ylab("przeliczony kurs úredni waluty") + 
      xlab("")

count_ts = ts(y[, c('currency.mid')])
y$clean_data = tsclean(count_ts)

ggplot(y, aes(x = date, y = clean_data, colour = currency.code)) + 
  geom_line(alpha=.9, size =1) + 
  scale_x_date("month") + 
  ylab("przeliczony kurs úredni waluty") + 
  xlab("")