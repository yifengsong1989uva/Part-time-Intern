args<-commandArgs(TRUE)

library(xlsx)
library(sqldf)
library(stringr)


clean_mp_data <- function(df) {
  df$number_of_distinct_user_visits <- NULL
  df$number_of_quick_link_visits <- NULL
  df$company_name <- as.character(df$company_name)
  df$company_name[df$company_name=="Environmental Defense Fund (EDF)"]<-"EDF"
  df$company_name[df$company_name=="L'Oréal"]<-"L'Oreal"
  df$company_name[df$company_name=="Nestlé USA"]<-"Nestle"
  return(df)
}

mmss_to_secs <- function(mmss) {
  mmss_v <- as.numeric(str_split(mmss,":")[[1]])
  return(mmss_v[1]*60+mmss_v[2])
}

secs_to_mmss <- function(secs) {
  mm <- str_pad(as.character(secs%/%60), width = 2, pad = '0', side = 'left')
  ss <- str_pad(as.character(secs%%60), width = 2, pad = '0', side = 'left')
  return(str_c(mm,ss,sep=":"))
}


setwd('/home/composersyf/Documents/RelishMBA/Monthly_Employer_Digest')
df1 <- read.xlsx('Employer Accounts .xlsx',sheetIndex = 1)
df1[,18] <- NULL
df1[,18] <- NULL
df1[,18] <- NULL
df1[,18] <- NULL


setwd('/home/composersyf/Documents/RelishMBA/MixPanel_Data')
df_mp1 <- read.csv(paste0("Company_Sites_Popularity_",str_replace_all(args[2],"-","_"),".csv"))
df_mp2 <- read.csv(paste0("Monthly_Company_Sites_Polularity (",args[1]," to ",args[2],").csv"))
df_mp1 <- clean_mp_data(df_mp1)
df_mp2 <- clean_mp_data(df_mp2)


df2 <- sqldf("select df1.*, df_mp1.*
              from df1
              inner join df_mp1
              on df1.Company = df_mp1.company_name")
df2 <- df2[,c(1:5,19:21)]
colnames(df2) <- c("Email Address","First Name","Last Name","Company","Company_Number",
                   "Visits","Follows","Saves")


setwd('/home/composersyf/Documents/RelishMBA/Google_Analytics_Data/Avg_Time_on_Site')
df_ga1 <- read.csv(paste0("Overall_Average_Time_on_Company_Page/Overall_Average_Time_on_Company_Page_",str_replace_all(args[2],"-","_"),".csv"), stringsAsFactors = F)
df_ga2 <- read.csv(paste0("Monthly_Avg_Time_on_Company_Page/Average_Time_on_Company_Page--",str_replace_all(args[1],"-","_"),"_to_",str_replace_all(args[2],"-","_"),".csv"), stringsAsFactors = F)
df3 <- sqldf("select df2.*, df_ga1.Avg_Time_on_Page
              from df2
              inner join df_ga1
              on df2.Company_Number = df_ga1.company_id")
colnames(df3)[9]<-"Time on Page" 


df4 <- sqldf("select df3.*, df_mp2.*
              from df3
              left outer join df_mp2
              on df3.Company = df_mp2.company_name")
df4$company_name <- NULL
colnames(df4)[-seq(1,ncol(df4)-3)] <- c("New Visits","New Follows","New Saves")
df4[,-seq(1,ncol(df4)-3)][is.na(df4[,-seq(1,ncol(df4)-3)])] <- 0


df5 <- sqldf("select df4.*, df_ga2.Avg_Time_on_Page
              from df4
              left outer join df_ga2
              on df4.Company_Number = df_ga2.company_id")
df5[,ncol(df5)][is.na(df5[,ncol(df5)])] <- "00:00"
colnames(df5)[ncol(df5)] <- "Recent Avg Time on Page"


mean_mp2 <- sapply(colMeans(df_mp2[,-1]),round,2)
avg_time_secs <- round(sum(sapply(df_ga2$Avg_Time_on_Page,mmss_to_secs))/nrow(df_mp1))
avg_time <- secs_to_mmss(avg_time_secs)
last_four_cols <- as.data.frame(t(as.data.frame(c(mean_mp2,avg_time))))
df6 <- sqldf("select df5.*, last_four_cols.*
              from df5
              cross join last_four_cols")
df6 <- df6[,c(1:9,10,14,13,17,11,15,12,16)]
colnames(df6)[c(5,11,13,15,17)] <- c("Company Number", "Benchmark - Visits",
                                     "Benchmark - Time", "Benchmark - Follows",
                                     "Benchmark - Saves")


write.xlsx(df6, "../../Monthly_Employer_Digest/Employer Accounts New.xlsx",row.names = F, showNA = F)