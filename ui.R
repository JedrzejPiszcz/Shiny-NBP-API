library(shiny)
library(DT)

shinyUI(
  fluidPage(
    titlePanel(windowTitle = "Programming Internet Applications CM 2017",
               title = "Programming Internet Applications CM 2017"
               # title = div(img(src = "logo_black.png",
               #                 width = "10%",
               #                 style = "margin:5px 20px"))
               ),
    sidebarPanel(
       selectInput("currenciesByNameAndCode", 
                   label = "Select currency by name:",
                   choices = Currencies$nameAndCode,
                   selected = Currencies$nameAndCode[1],
                   multiple = T),
       dateRangeInput("dateRange", 
                      label = "Select date range:", 
                      start = "2010-01-01", 
                      end = Sys.Date()),
       radioButtons("tableSelection",
                    label = "Select type of course",
                    choices = Tables, 
                    #selected = Tables[1],
                    inline = TRUE)
      #uiOutput("delayRange"),
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Delay over day",
                 plotOutput('ddelay_plot', hover = "plot_hover", click = "plot_click")
        ),
        tabPanel("Explore data",
                 dataTableOutput("table")
        )  
      )
    ),
    verbatimTextOutput("info")
  )
)

