library(dygraphs)

weekly_page_visits <- read.csv("Weekly_Page_Visits.csv")
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Weekly Company Sites Popularity since January 2016"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      selectInput("company_name",
                  label = "Select a Company:",
                  choices = as.character(weekly_page_visits$company_name)
      )
    ),


    # Show a plot of the generated distribution
    mainPanel(
      dygraphOutput("dygraph1"),
      dygraphOutput("dygraph2"),
      dygraphOutput("dygraph3"),
      dygraphOutput("dygraph4")
    )
  )
))
