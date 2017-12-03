library(ggplot2)
library(dplyr)
library(ggthemes)
library(DT)

shinyServer(function(input, output, session) {
  
  tmpData <- reactive({
    modFlights %>% 
    filter(name %in% input$carrierName)
  })
  
  output$delayRange <- renderUI({
    
    max_delay <- max(tmpData()$dep_delay)
    
    sliderInput('delayFlightRange',
                label = "Choose minutes range of delayed flights:",
                min = 0, max = max_delay,
                value = c(0, 1000), step = 10)
  })
  
  dayFilteredData <- reactive({
    tmpData() %>% 
      group_by(name, hour) %>% 
      summarise(delayed_flight_perc = sum(dep_delay > input$delayFlightRange[1] & dep_delay < input$delayFlightRange[2] & distance > input$distance_val) / 
                  sum(distance > input$distance_val))
  })
  
  output$ddelay_plot <- renderPlot({
    
    ggplot(dayFilteredData(), aes(hour, delayed_flight_perc, fill = name)) + 
      geom_col(position = 'dodge') +
      theme_hc(base_size = 18) + 
      scale_fill_hc() +
      xlab("Hour") +
      ylab("Percentage of delayed flights") +
      scale_y_continuous(labels = scales::percent) +
      scale_x_continuous(limits = c(0,24), breaks = seq(0, 24, 2))
    
  })
  
  output$table <- renderDataTable({
    datatable(dayFilteredData()) %>% 
      formatPercentage(3)
  })
  
  output$info <- renderText({
    paste0("x=", input$plot_hover$x, "\ny=", input$plot_hover$y)
  })
})
