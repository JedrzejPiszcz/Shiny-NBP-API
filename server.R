library(ggplot2)
library(dplyr)
library(ggthemes)
library(DT)

shinyServer(function(input, output, session) {
  
  filteredData <- reactive({
    finalResult %>% 
    filter(nameAndCode %in% input$currenciesByNameAndCode) %>%
    filter(table %in% input$tableSelection)
  })
  
  # output$delayRange <- renderUI({
  #   
  #   max_delay <- max(tmpData()$dep_delay)
  #   
  #   sliderInput('delayFlightRange',
  #               label = "Choose minutes range of delayed flights:",
  #               min = 0, max = max_delay,
  #               value = c(0, 1000), step = 10)
  # })
  
  # dayFilteredData <- reactive({
  #   tmpData() %>% 
  #     group_by(name, hour) %>% 
  #     summarise(delayed_flight_perc = sum(dep_delay > input$delayFlightRange[1] & dep_delay < input$delayFlightRange[2] & distance > input$distance_val) / 
  #                 sum(distance > input$distance_val))
  # })
  
  output$ddelay_plot <- renderPlot({

    ggplot(filteredData(), aes(x = as.Date(date), y = currency.mid, colour = currency.code)) + 
      geom_line(alpha=.9, size =1) + 
      scale_x_date("month") + 
      ylab("Calculated Average Course") + 
      xlab("")

  })
  
  output$table <- renderDataTable({
    datatable(filteredData())
  })
  
  output$info <- renderText({
    paste0("x=", input$plot_hover$x, "\ny=", input$plot_hover$y)
  })
})
