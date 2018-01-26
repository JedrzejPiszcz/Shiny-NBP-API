library(shiny)
library(DT)

shinyUI(
  fluidPage(
    titlePanel(windowTitle = "Programming Internet Applications CM 2017",
               title = div(img(src = "put3_logo.png",
                                width = "30%",
                                style = "margin:5px 20px"))
               ),
    sidebarPanel(
       # selectInput("currenciesByNameAndCode", 
       #             label = "Select currency by name:",
       #             choices = Currencies$nameAndCode,
       #             selected = Currencies$nameAndCode[1],
       #             multiple = T),
       uiOutput("currenciesByNameAndCode"),
       
       dateRangeInput("dateRange", 
                      label = "Select date range:", 
                      start = "2017-01-01", 
                      end = Sys.Date(),
                      min = "2010-01-01",
                      max = Sys.Date()),
       
       radioButtons("tableSelection",
                    label = "Select type of table",
                    choices = Tables, 
                    inline = TRUE),
       
       uiOutput("courseTypeSelection")
      #uiOutput("delayRange"),
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Course in time range",
                 plotlyOutput('coursePlot')
        ),
        tabPanel("Explore data",
                 dataTableOutput("table")
        )  
      )
    )
    #verbatimTextOutput("info"),

  )
)

