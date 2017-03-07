# -*- coding: utf-8 -*-
"""
Created on Thu Aug  4 17:53:23 2016

@author: composersyf
"""

import os
import glob
import numpy as np
import pandas as pd

os.chdir("/home/composersyf/Documents/RelishMBA/Google_Analytics_Data/Avg_Time_on_Site")


def clean_dates(fname):
    return fname.split('/')[-1].split("--")[-1].split(".")[0].replace("_to_"," - ").replace("_","/")


def merge_tables(file_list):
    data_table=pd.read_csv(file_list[0])
    data_table=data_table.rename(columns={"Avg_Time_on_Page":clean_dates(file_list[0])})
    
    for i in range(1,len(file_list)):
        right_table=pd.read_csv(file_list[i])
        right_table=right_table.iloc[:,[0,2]]
        right_table=right_table.rename(columns={"Avg_Time_on_Page":clean_dates(file_list[i])})
        data_table=data_table.merge(right_table,on=['company_name'],how="outer")
        
    data_table=data_table.fillna("00:00")

    keep_columns=list(np.array(range(data_table.shape[1]))[0:1])+list(np.array(range(data_table.shape[1]))[2:])
    data_table=data_table.iloc[:,keep_columns]
    company_id=pd.read_csv("/home/composersyf/Documents/RelishMBA/MixPanel_Data/company_id.csv")
    company_id.columns=["company_name","company_id"]
    data_table=company_id.merge(data_table,on="company_name",how="outer")
    new_order=np.argsort(data_table['company_name'].apply(str.lower))
    data_table=data_table.iloc[new_order,:]    
    
    data_table.to_csv("Weekly_Avg_Time_on_Company_Page.csv",index=False)
    

def main():
    file_list=glob.glob("Weekly_Avg_Time_on_Company_Page/Average*")
    file_list=sorted(file_list)
    merge_tables(file_list)
    

if __name__=='__main__':
    main()