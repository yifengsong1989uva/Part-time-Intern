"""Query the Google Analytics Reporting API V4, using Python 2.7 Client Library."""

import sys
import os
os.chdir('/home/composersyf/Documents/RelishMBA/Google_Analytics_Data/Avg_Time_on_Site')

import argparse

from apiclient.discovery import build
from oauth2client.service_account import ServiceAccountCredentials

import httplib2
from oauth2client import client
from oauth2client import file
from oauth2client import tools

import numpy as np
import pandas as pd


SCOPES = ['https://www.googleapis.com/auth/analytics.readonly']
DISCOVERY_URI = ('https://analyticsreporting.googleapis.com/$discovery/rest')
KEY_FILE_LOCATION = 'My Project 1-8873a4cc8f56.p12'
SERVICE_ACCOUNT_EMAIL = 'data-export@airy-legacy-137221.iam.gserviceaccount.com'
VIEW_ID = '103322601'


def initialize_analyticsreporting():
  """Initializes an analyticsreporting service object.

  Returns:
    analytics an authorized analyticsreporting service object.
  """

  credentials = ServiceAccountCredentials.from_p12_keyfile(
    SERVICE_ACCOUNT_EMAIL, KEY_FILE_LOCATION, scopes=SCOPES)

  http = credentials.authorize(httplib2.Http())

  # Build the service object.
  analytics = build('analytics', 'v4', http=http, discoveryServiceUrl=DISCOVERY_URI)

  return analytics


def get_avg_time_report(analytics,startDate=sys.argv[1],endDate=sys.argv[2]):
  # Use the Analytics Service Object to query the Analytics Reporting API V4.
  # See https://developers.google.com/analytics/devguides/reporting/core/v4/rest/v4/reports/batchGet for request body parameters
  # Also see https://developers.google.com/analytics/devguides/reporting/core/v4/samples for examples in Python
  
  return analytics.reports().batchGet(
      body={
        'reportRequests': [
        {
          'viewId': VIEW_ID,
          'dateRanges': [{'startDate': startDate, 'endDate': endDate}],
          'dimensions':[{'name': 'ga:pagePath'}],
          'metrics': [{'expression': 'ga:pageviews'},
                      {'expression': 'ga:timeOnPage'},
                      {'expression': 'ga:avgTimeOnPage'}],
          'dimensionFilterClauses': [{'filters':[{'dimensionName':'ga:pagePath',
                                                  'operator':'PARTIAL',
                                                  'expressions':['/show_public_page']}]}],
          'pageSize':10000

        }]
      }
  ).execute()


def organize_response(response):
    """Parses the raw Analytics Reporting API V4 response (JSON format) transform
    into dataFrame format"""
  
    data=response['reports'][0]['data']['rows']
    data_list=[]
    for i in range(len(data)):
        data_list.extend(data[i]['dimensions']+data[i]['metrics'][0]['values'])
    data_list=np.array(data_list)
    data_list=data_list.reshape(data_list.shape[0],1)
    data_list=data_list.reshape(data_list.shape[0]/4,4)
    data_df=pd.DataFrame(data_list)
    data_df.columns=['Page','Pageviews','Time on Page','Avg. Time on Page']
    
    time_window=sys.argv[1][5:]+"-"+sys.argv[1][:4]+"_to_"+sys.argv[2][5:]+"-"+sys.argv[2][:4]
    data_df.to_csv("Monthly_Avg_Time_on_Company_Page/"+time_window.replace("-","_")+".csv",index=False)
    print time_window.replace("-","_")+".csv"
    

def main():
    analytics = initialize_analyticsreporting()
    response = get_avg_time_report(analytics)
    organize_response(response)


if __name__ == '__main__':
    main()
