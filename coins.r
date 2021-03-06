#Install Packages
install.packages(c("shiny", "tidyverse", "shinydashboard", "rvest"));

#Load the installed Packages
library(shiny)
library(tidyverse)
library(shinydashboard)
library(rvest)

#Functions to get all data in the URL and store it on a dataFrame
get.data <- function(x){
  
  #read the site as webpage
  myurl <- read_html("https://coinmarketcap.com/gainers-losers/")
  
  #convert html table to R Object
  myurl <- html_table(myurl)
 
  
  #get first item on the list
  to.parse <- myurl[[1]]
  
  
  #data clean-up removing extra chars
  to.parse$`% 1h` <- gsub("%","",to.parse$`% 1h`)
 
  
  #convert % column to numerals, so we can sort em out.
  to.parse$`% 1h`<- as.numeric(to.parse$`% 1h`)
  
  
  #convert Coin Symbol to factor
  to.parse$Symbol <- as.factor(to.parse$Symbol)
  
  #Sort by gain value and return the dataFrame
  to.parse$Symbol <- factor(to.parse$Symbol,
                            levels = to.parse$Symbol[order(to.parse$'% 1h')])
  
  #return finished dataFrame
  to.parse
  
}

#Function to get highest value
get.infobox.val <- function(x){
  df1 <- get.data()
  df1 <- df1$`% 1h`[1]
  df1
}

#Function to get all top coin
get.infobox.val <- function(x) {
  df1 <- get.data()
  df1 <- df1$`% 1h`[1]
  df1
}


### Shiny Front-End

ui <- dashboardPage(
  
  #This is the header
  dashboardHeader(title = "Coin Gainers"),
  
  #This is the Sidebar
  dashboardSidebar(
    
    h5("Coin Gainers from CoinMarketCap"),
    br(),
    br(),
    br(),
    br(),
    br(),
    br(),
    br(),
    br(),
    br(),
    br(),
    h6("Built by Brad Lindblad in the R computing language and developed in GitHub by KBPsystem777
      [  R Core Team (2018). R: A language and environment for statistical computing.
          R Foundation for Statistical Computing,
       Vienna, Austria. URL https://www.R-project.org/]"),
    br(),
    a("bradley.lindblad@gmail.com", href="bradley.lindblad@gmail.com"),
    a("KBPsystem777", href="https://github.com/kbpsystem777")
  ),
  
  
  #This is the Body
  dashboardBody(
    fluidRow(
      # Info Box
      infoBoxOutput("top.coin", width = 3),
      # Info Box
      infoBoxOutput("top.name", width = 3)
    ),
    
    fluidRow(
      #Data Table
      box(
        status = "primary",
        headerPanel("Data Table"),
        solidHeader = T,
        br(),
        DT::dataTableOutput("table", height = "350px"),
        width = 6,
        height = "560px"
      ),

      #this is the Chart
      box(
          status = "primary",
          headerPanel("Chart"),
          solidHeader = T,
          br(),
          plotOutput("plot", height = "400px"),
          width = 6,
          height = "500px"
      ),
      width = 12      
    )
  )  
)


####Server Part#####

server <- function(input, output){
    liveish_data <- reactive({
        #Refresh the data Every 60secs
        invalidateLater(60000)
        get.data()
    })

    live.infobox.val <- reactive({
        invalidateLater(60000)
        get.infobox.val()
    })

    live.infobox.coin <- reactive({
        invalidateLater(60000)
        get.infobox.coin()
    })


    ##Output data table
    output$table <- DT::renderDataTable(DT::datatable({
        data <- liveish_data()
    }))

    ##Plotting the Output
    output$plot <- renderPlot({ (gglplot(data=liveish_data(), aes(
        x=Symbol, y=`% 1h`)) + geom_bar(stat="identify", fill = "springgreen3") + theme(axis.text.x = element_text(angle = 90, hjust = 1)) + 
        ggtitle("Gainers from the last hour"))
    })

    ##Info Box Output
    output$top.coin <- renderInfoBox({
        infoBox(
            "Gain in Last Hour",
            paste0(live.infobox.val(), "%"),
            icon = icon("signal"),
            color = "purple",
            fill = TRUE
        )
    })

    ##Info Box Output Coin Names
    output$top.name <- renderInfoBox({
        infoBox(
            "Coin Name",
            live.infoBox.coin(),
            icon = icon("bitcoin"),
            color = "purple",
            fill = TRUE
        )
    })
}



###Deployment

shinyApp(ui = ui, server = server);




