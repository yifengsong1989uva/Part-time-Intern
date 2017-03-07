# -*- coding: utf-8 -*-
"""
Created on Mon Jun 13 15:29:24 2016

@author: composersyf
"""

from bs4 import BeautifulSoup
import urllib.request
import re



######################################
### I. scraping company facebook sites
company_facebook_url=["https://www.facebook.com/3M/",
                      "https://www.facebook.com/bainandcompany/",
                      "https://www.facebook.com/BBTBank/",
                      "https://www.facebook.com/BizCorps-157194631095653/",
                      "https://www.facebook.com/Chevron",
                      "https://www.facebook.com/CIGNA/",
                      "https://www.facebook.com/corningincorporated",
                      "https://www.facebook.com/Crane/",
                      "https://www.facebook.com/dupontco/",
                      "https://www.facebook.com/pages/E-J-Gallo-Winery/135011546541742",
                      "https://www.facebook.com/EmersonCorporate/",
                      None,
                      "https://www.facebook.com/Forcier-Consulting-217301328286526/",
                      "https://www.facebook.com/ford/",
                      None,
                      "https://www.facebook.com/Humana",
                      None,
                      "https://www.facebook.com/MandTBank/",
                      None,
                      "https://www.facebook.com/Nestle/",
                      "https://www.facebook.com/pages/Peer-Insight/781875505191417",
                      "https://www.facebook.com/pwcfanpage/"
                      ]

number_of_likes=[]
for i,url in enumerate(company_facebook_url):
    if url is None:
        number_of_likes.append(None)
    elif i==9 or i==20:
        html = urllib.request.urlopen(url).read()
        soup=BeautifulSoup(html,'html.parser')
        meta=soup.findAll("meta")
        content=[]
        for i in meta:
            try:
                content.append(i['content'])
            except KeyError:
                pass
        str_pattern=re.compile("[,0-9]{1,} likes")
        for i in content:
            str_result=re.findall(str_pattern,i)
            if len(str_result)==1:
                break
        number=str_result[0].split()[0]
        number_of_likes.append(number)
    else:                                     
        html = urllib.request.urlopen(url).read()
        soup=BeautifulSoup(html,'html.parser')
        number=soup.findAll("span",{"id":"PagesLikesCountDOMID"})[0].findAll("span")[0].get_text().split()[0]
        number_of_likes.append(number)



######################################
### II. scraping company twitter sites
company_twitter_url=["https://twitter.com/3m",
                     "https://twitter.com/BainAlerts",
                     "https://twitter.com/askbbt",
                     "https://twitter.com/bizcorps",
                     "https://twitter.com/chevron",
                     "https://twitter.com/Cigna",
                     "https://twitter.com/corning",
                     None,
                     "https://twitter.com/DuPont_News",
                     "https://twitter.com/gallofamily",
                     "https://twitter.com/Emerson_news",
                     None,
                     "https://twitter.com/4CAConsulting",
                     "https://twitter.com/Ford",
                     None,
                     "https://twitter.com/humana",
                     "https://twitter.com/kiwitechcorp",
                     "https://twitter.com/MandT_Bank",
                     "https://twitter.com/morganstanley",
                     "https://twitter.com/NestleUSA",
                     "https://twitter.com/peerinsight",
                     "https://twitter.com/pwc_llp"]

number_of_followers=[]
for url in company_twitter_url:
    if url is None:
        number_of_followers.append(None)
    else:
        html = urllib.request.urlopen(url).read()
        soup=BeautifulSoup(html,'html.parser')
        all_a_tags=soup.findAll("a")
        all_titles=[]
        for t in all_a_tags:
            try:
                all_titles.append(t["title"])
            except KeyError:
                pass
        for t in all_titles:
            if "Followers" in t:
                number=t.split()[0]
                number_of_followers.append(number)
                break
            else:
                pass
   
   
   
#################################         
### III. export the scraped data
import numpy as np
import pandas as pd
table=pd.DataFrame({"Number_of_Facebook_Likes":number_of_likes,
                    "Number_of_Twitter_followers":number_of_followers})
table.to_csv("scraped_data_1.csv")