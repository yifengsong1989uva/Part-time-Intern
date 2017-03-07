#!/bin/bash

cd Documents/RelishMBA/Google_Analytics_Data/Avg_Time_on_Site
source activate py27

filename=`python Query_Google_Analytics_API_Overall_Time_on_Page.py "2016-01-01" "2017-02-28"`
Rscript Time_on_Company_Page_Overall.R $filename

source deactivate
cd ~
