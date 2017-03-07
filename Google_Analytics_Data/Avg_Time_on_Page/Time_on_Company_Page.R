args<-commandArgs(TRUE) #allows for adding arguments when calling the R script from the command line

library(stringr)
library(sqldf)
setwd("/home/composersyf/Documents/RelishMBA/Google_Analytics_Data/Avg_Time_on_Site")



### (1) Clean the raw company page timing data, combine the rows have are essentially pages from the same company
mydata <- read.csv(paste0("Weekly_Avg_Time_on_Company_Page/",args[1]))
mydata$Pageviews <- NULL

mydata$Page <- as.character(mydata$Page)
for (i in 1:length(mydata$Page)) {
  mydata$Page[i]=str_c(str_split(mydata$Page[i],"/")[[1]][1:4],collapse="/")
}

colnames(mydata)[2:3] <- c("Time_on_Page","Avg_Time_on_Page")
mydata$Page_Views <- round(mydata$Time_on_Page/mydata$Avg_Time_on_Page)
mydata$Page_Views[is.na(mydata$Page_Views)]=0
mydata$Page_Views[which(mydata$Page_Views==Inf)]=1
mydata$Avg_Time_on_Page <- NULL

mydata1 <- sqldf("select Page, sum(Page_Views) as Pageviews, sum(Time_on_Page) as Time_on_Page
                  from mydata
                  group by Page")
mydata1$company_id <- rep("",nrow(mydata1))

for (i in 1:nrow(mydata1)) {
  mydata1$company_id[i] <- str_split(mydata1$Page[i],"/")[[1]][3]
}

mydata1$Avg_Time_on_Page <- mydata1$Time_on_Page/mydata1$Pageviews

mydata1$Avg_Time_on_Page[is.na(mydata1$Avg_Time_on_Page)]=0



### (2) Join the avg. time on page result with the company_id ~ company_page table
company_id_name <- read.csv("/home/composersyf/Documents/RelishMBA/MixPanel_Data/company_id.csv")
colnames(company_id_name) <- c('company_name','company_id')

mydata2 <- sqldf("select t1.company_name, t2.Avg_Time_on_Page
                  from company_id_name t1
                  inner join mydata1 t2
                  on t1.company_id=t2.company_id")

mydata2$Avg_Time_on_Page <- round(mydata2$Avg_Time_on_Page)

to_minutes <- function(s) {
  mm <- s %/% 60
  ss <- s %% 60
  mm <- str_pad(as.character(mm), width=2, side="left", pad="0")
  ss <- str_pad(as.character(ss), width=2, side="left", pad="0")
  return(paste(mm,ss,sep=":"))
}

mydata2$Avg_Time_on_Page <- sapply(mydata2$Avg_Time_on_Page,to_minutes)
mydata2$company_name <- as.character(mydata2$company_name)

company_id_name$company_name <- as.character(company_id_name$company_name)

mydata3 <- sqldf("select t1.*, t2.Avg_Time_on_Page
                  from company_id_name t1
                  inner join mydata2 t2
                  on t1.company_name=t2.company_name")

mydata4 <- mydata3[order(str_to_lower(mydata3$company_name)),]



### (3) writing to .csv file
write.csv(mydata4,file=paste0("Weekly_Avg_Time_on_Company_Page/Average_Time_on_Company_Page--",args[1]),
          row.names=F)