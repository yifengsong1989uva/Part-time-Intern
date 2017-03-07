#!/bin/bash

cd Documents/RelishMBA/Google_Analytics_Data/Avg_Time_on_Site
source activate py27

date1=$1
date2=$2

filename=`python Query_Google_Analytics_API_Monthly_Time_on_Page.py $date1 $date2`
Rscript Time_on_Company_Page_Monthly.R $filename

source deactivate
cd ~
