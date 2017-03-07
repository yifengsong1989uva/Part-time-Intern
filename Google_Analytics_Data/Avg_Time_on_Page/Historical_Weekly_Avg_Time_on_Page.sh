#!/bin/bash

cd Documents/RelishMBA/Google_Analytics_Data/Avg_Time_on_Site
source activate py27

python Generate_Weekly_Periods.py > Weekly_Periods.txt
sed 's/ - /!/g' Weekly_Periods.txt > Weekly_Periods_new.txt

while read -r line
do
    time_window="$line"
    date1=`echo $time_window | cut -d \! -f 1`
    date2=`echo $time_window | cut -d \! -f 2`
    filename=`python Query_Google_Analytics_API_Weekly_Time_on_Page.py $date1 $date2`
    Rscript Time_on_Company_Page.R $filename
done < "Weekly_Periods_new.txt"

python Merge_Weekly_Time_on_Page_Data.py
cp Weekly_Avg_Time_on_Company_Page.csv '/home/composersyf/Documents/RelishMBA/Shiny_dygraphs'

source deactivate
cd ~
