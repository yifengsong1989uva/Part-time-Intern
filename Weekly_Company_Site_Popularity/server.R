library(dygraphs)
library(xts)
library(stringr)
library(data.table)

mmss_to_secs <- function(mmss) {
  mm_ss <- str_split(mmss,":")[[1]]
  mm <- as.numeric(mm_ss[1])
  ss <- as.numeric(mm_ss[2])
  return(60*mm+ss)
}

weekly_page_visits <- read.csv("Weekly_Page_Visits.csv")
weekly_company_saves <- read.csv("Weekly_Company_Saves.csv")
weekly_company_follows <- read.csv("Weekly_Company_Follows.csv")
weekly_avg_time_on_page <- read.csv("Weekly_Avg_Time_on_Company_Page.csv")
weekly_avg_time_on_page$company_id <- NULL

datetimes <- seq.POSIXt(as.POSIXct(gsub("[.]", "-" ,str_sub(colnames(weekly_page_visits)[2],-10,-1)), tz="EST"),
                        as.POSIXct(gsub("[.]", "-" ,str_sub(colnames(weekly_page_visits)[ncol(weekly_page_visits)],-10,-1)), tz="EST"), by="1 week")

start_time <- seq.POSIXt( as.POSIXct(gsub("[.]", "-" ,str_sub(colnames(weekly_page_visits)[2],-10,-1)), tz="EST"), by="-1 week", length.out=2)[2]
end_time <- seq.POSIXt( as.POSIXct(gsub("[.]", "-" ,str_sub(colnames(weekly_page_visits)[ncol(weekly_page_visits)],-10,-1)), tz="EST"), by="1 week", length.out=2)[2]

# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyServer(function(input, output) {

  output$dygraph2 <- renderDygraph({

    values <- transpose(weekly_company_saves[weekly_company_saves$company_name==input$company_name,][1,2:ncol(weekly_company_saves)])$V1
    series <- xts(values, order.by = datetimes, tz="EST")
    colnames(series) <- "#_of_saves"

    dygraph(series, main="Number of Saves vs. Time", group="Sites Polularity", xlab = "Date",ylab = "Number of Saves") %>%
      dySeries("#_of_saves",color="red",drawPoints=T,pointSize=4.5,strokeWidth=2) %>%
      dyAxis("x",valueRange = c(start_time,end_time)) %>%
      dyAxis("y",valueRange = c(min(values)-2, max(values)+5)) %>%
      dyHighlight(highlightCircleSize = 6.5, hideOnMouseOut = T) %>%
      dyRangeSelector(height = 15, dateWindow = c(start_time,end_time))

  })
  
  output$dygraph1 <- renderDygraph({
    
    values <- transpose(weekly_page_visits[weekly_page_visits$company_name==input$company_name,][1,2:ncol(weekly_page_visits)])$V1
    series <- xts(values, order.by = datetimes, tz="EST")
    colnames(series) <- "#_of_visits"
    
    dygraph(series, main="Number of Visits vs. Time", group="Sites Polularity", xlab = "Date",ylab = "Number of Visits") %>%
      dySeries("#_of_visits",color="green",drawPoints=T,pointSize=4.5,strokeWidth=2) %>%
      dyAxis("x",valueRange = c(start_time,end_time)) %>%
      dyAxis("y",valueRange = c(min(values)-2, max(values)+5)) %>%
      dyHighlight(highlightCircleSize = 6.5, hideOnMouseOut = T) %>%
      dyRangeSelector(height = 15, dateWindow = c(start_time,end_time))
    
  })
  
  output$dygraph3 <- renderDygraph({
    
    values <- transpose(weekly_company_follows[weekly_company_follows$company_name==input$company_name,][1,2:ncol(weekly_company_follows)])$V1
    series <- xts(values, order.by = datetimes, tz="EST")
    colnames(series) <- "#_of_follows"
    
    dygraph(series, main="Number of Follows vs. Time", group="Sites Polularity", xlab = "Date",ylab = "Number of Follows") %>%
      dySeries("#_of_follows",color="blue",drawPoints=T,pointSize=4.5,strokeWidth=2) %>%
      dyAxis("x",valueRange = c(start_time,end_time)) %>%
      dyAxis("y",valueRange = c(min(values)-2, max(values)+5)) %>%
      dyHighlight(highlightCircleSize = 6.5, hideOnMouseOut = T) %>%
      dyRangeSelector(height = 15, dateWindow = c(start_time,end_time))
    
  })
  
  output$dygraph4 <- renderDygraph({
    
    values <- transpose(weekly_avg_time_on_page[weekly_avg_time_on_page$company_name==input$company_name,][1,2:ncol(weekly_avg_time_on_page)])$V1
    values <- sapply(values,mmss_to_secs)
    series <- xts(values, order.by = datetimes, tz="EST")
    colnames(series) <- "avg._duration_on_page"
    
    dygraph(series, main="Avg. Duration on Page vs. Time", group="Sites Polularity", xlab = "Date",ylab = "Avg. Duration (s)") %>%
      dySeries("avg._duration_on_page",color="blue",drawPoints=T,pointSize=4.5,strokeWidth=2) %>%
      dyAxis("x",valueRange = c(start_time,end_time)) %>%
      dyAxis("y",valueRange = c(min(values)-20, max(values)+125)) %>%
      dyHighlight(highlightCircleSize = 6.5, hideOnMouseOut = T) %>%
      dyRangeSelector(height = 15, dateWindow = c(start_time,end_time))
    
  })

})