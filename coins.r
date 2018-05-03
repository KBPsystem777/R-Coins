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







