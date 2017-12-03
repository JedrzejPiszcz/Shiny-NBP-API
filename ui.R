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
      selectInput("carrierName", 
                  label = "Select carrier:",
                  choices = chosenCarrier$name,
                  selected = chosenCarrier$name[1],
                  multiple = T),
      uiOutput("delayRange"),
      numericInput("distance_val", label = "Flight distance longer than (in miles)", value = 500)
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

