library(nycflights13)
library(dplyr)
options(scipen = 999)

source("./NBPAPIfunctions.R")

validStartDate<-as.Date("2017-01-01")
validEndDate<-as.Date("2017-12-01")

finalResult<-getDataFromDateRange(validStartDate = validStartDate, validEndDate = validEndDate)
finalResult$date<-as.Date(finalResult$date)
finalResult$nameAndCode<- paste0(finalResult$currency.code, " | ", finalResult$currency.name)
#finalResult <-finalResult %>% filter(table %in% c("A")) %>% filter(currency.code %in% c("EUR", "USD")) 
Currencies<-finalResult[!duplicated(finalResult$currency.code), c("currency.code", "currency.name", "nameAndCode")]
Currencies<-Currencies[order(Currencies$nameAndCode),]
Tables<-finalResult[!duplicated(finalResult$table), c("table")]

# flights <- flights
# airlines <- airlines
# 
# # łączenie dwóch dataframe'ów
# modFlights <- flights %>% 
#   inner_join(airlines, by = 'carrier')
# 
# # wybór siedmu linii lotniczych
# chosenCarrier <- modFlights %>% count(name) %>% 
#   arrange(desc(n)) %>% 
#   head(7)
# 
# # filtrowanie danych 
# modFlights <- modFlights %>% 
#   filter(!is.na(dep_delay), name %in% chosenCarrier$name)
