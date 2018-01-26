library(ggplot2)
library(dplyr)
library(ggthemes)
library(DT)

shinyServer(function(input, output, session) {
  
  
  filteredCurrencies<-reactive({
   
    temp<-Currencies %>% 
      filter(table %in% input$tableSelection)
    temp<-temp[order(temp$nameAndCode),]
    
    return(temp)
  })
  
  freshDataInDateRange<-reactive({
    
    finalResult<-getDataFromDateRange(validStartDate = as.Date(input$dateRange[1]), validEndDate = as.Date(input$dateRange[2]))
    finalResult$date<-as.Date(finalResult$date)
    finalResult$nameAndCode<- paste0(finalResult$currency.code, " | ", finalResult$currency.name)
    
    return(finalResult)
  })
  
  filteredData <- reactive({
    tempData<-NA
    if(nrow(freshDataInDateRange())>=0){ 
      tempData<-freshDataInDateRange()
    }else{
      tempData<-finalResult
    }

    temp<- tempData %>%
      filter(table %in% input$tableSelection) %>%
      filter(nameAndCode %in% input$currenciesByNameAndCode)
    
    return(temp)
  })
  
  rm(finalResult)
  
  output$currenciesByNameAndCode <-renderUI({
    
    temp<-filteredCurrencies()
    
    selectInput("currenciesByNameAndCode", 
                 label = "Select currency by name:",
                 choices = temp$nameAndCode,
                 selected = temp$nameAndCode[1],
                 multiple = T)
    
  })
  
  output$courseTypeSelection <- renderUI({
    
    acceptableTypes<-filteredData()[which(filteredData()$table %in% input$tableSelection),c("currency.mid", "currency.bid", "currency.ask")]
    selectableTypes<-list()
    if(!any(is.na(acceptableTypes$currency.mid))){selectableTypes<-c(selectableTypes, "currency.mid")}
    if(!any(is.na(acceptableTypes$currency.ask))){selectableTypes<-c(selectableTypes, "currency.ask")}
    if(!any(is.na(acceptableTypes$currency.bid))){selectableTypes<-c(selectableTypes, "currency.bid")}
    
    
    radioButtons("courseTypeSelection",
                 label = "Select type of course",
                 choices = selectableTypes, 
                 inline = TRUE)
  })
  
  output$coursePlot <- renderPlotly({
    dataToPlot<-filteredData()
    
    if("currency.mid" %in% input$courseTypeSelection){
      p<-plot_ly(data = dataToPlot, x = ~date, y = ~currency.mid, color = ~currency.code) %>%
        add_lines()
    }
    if("currency.bid" %in% input$courseTypeSelection){
      p<-plot_ly(data = dataToPlot, x = ~date, y = ~currency.bid, color = ~currency.code) %>%
        add_lines()
    }
    if("currency.ask" %in% input$courseTypeSelection){
      p<-plot_ly(data = dataToPlot, x = ~date, y = ~currency.ask, color = ~currency.code) %>%
        add_lines()
    }
    
    return(p)
  })
  
  output$table <- renderDataTable({
    datatable(filteredData())
  })
  

})
