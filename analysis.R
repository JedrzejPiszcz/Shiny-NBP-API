library(nycflights13)

flights <- flights
airlines <- airlines

# łączenie danych
tmpFlights <- flights %>% 
  inner_join(airlines, by = 'carrier') %>% 
  filter(!is.na(dep_delay))

# agregacja danych 
aggDelayFlights <- tmpFlights %>% 
  group_by(hour) %>% 
  summarise(delayed_flight_perc = sum(dep_delay > 0) / n())

# tworzenie wykresu
ggplot(aggDelayFlights, aes(hour, delayed_flight_perc)) + 
    geom_col(position = 'dodge') +
    theme_hc(base_size = 18) + 
    scale_fill_hc() +
    xlab("Hour") +
    ylab("Percentage of delayed flights") +
    scale_y_continuous(labels = scales::percent) +
    scale_x_continuous(limits = c(0,24), breaks = seq(0, 24, 2))
  