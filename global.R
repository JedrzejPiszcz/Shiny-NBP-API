library(nycflights13)
library(dplyr)
options(scipen = 999)

flights <- flights
airlines <- airlines

# łączenie dwóch dataframe'ów
modFlights <- flights %>% 
  inner_join(airlines, by = 'carrier')

# wybór siedmu linii lotniczych
chosenCarrier <- modFlights %>% count(name) %>% 
  arrange(desc(n)) %>% 
  head(7)

# filtrowanie danych 
modFlights <- modFlights %>% 
  filter(!is.na(dep_delay), name %in% chosenCarrier$name)
