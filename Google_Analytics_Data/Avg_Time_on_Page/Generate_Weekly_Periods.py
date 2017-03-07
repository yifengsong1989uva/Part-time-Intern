# -*- coding: utf-8 -*-
"""
Created on Thu Aug  4 16:48:28 2016

@author: composersyf
"""

import time
import os

os.chdir("/home/composersyf/Documents/RelishMBA/MixPanel_Data")

#starting time: 01/25/2016 (Monday)
start_time=1453698000000
week_to_msecs=7*24*3600*1000
number_of_weeks=(time.time()*1000-start_time)//week_to_msecs


def weekly_periods():
    for i in range(int(number_of_weeks)):
        current_time=time.localtime(start_time/1000+i*week_to_msecs/1000)
        next_time=time.localtime(start_time/1000+(i+6.0/7)*week_to_msecs/1000)
        time_window=str(current_time.tm_year)+"-"+str(current_time.tm_mon).zfill(2)+"-"+str(current_time.tm_mday).zfill(2)+" - "+\
        str(next_time.tm_year)+"-"+str(next_time.tm_mon).zfill(2)+"-"+str(next_time.tm_mday).zfill(2)
        print time_window


def main():
    weekly_periods()
    

if __name__=='__main__':
    main()