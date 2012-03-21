from BeautifulSoup import BeautifulSoup, NavigableString, Tag
import urllib2
import re
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy import *
from datetime import date, datetime
import time
#import datetime

Base = declarative_base()


class EventDetails(Base):
    __tablename__ = 'event_details'
    event_id = Column(Integer, primary_key=True)
    name = Column(String(255))
    start_date = Column(DateTime)
    end_date = Column(DateTime)
    contact_email = Column(String(255))
    contact_name  = Column(String(255))
    contact_number = Column(String(255))
    category = Column(String(255))
    event_type = Column(String(255))
    event_link = Column(String(2084))
    details_link = Column(String(2084))
    location = Column(String(255))
    description = Column(Text)

    def __init__(self, arg1, arg2):
        self.name = arg1.encode('utf-8')
        self.event_link = arg2.encode('utf-8')
        self.start_date = ""
        self.end_date = ""
        self.contact_email = ""
        self.contact_name = ""
        self.contact_number = ""
        self.category = ""
        self.event_type = ""
        self.details_link = ""
        self.location = ""
        self.description = ""

    def display(self):
        print self.name
        print self.event_link
        print self.start_date
        print self.end_date
        print self.contact_email
        print self.contact_name
        print self.contact_number
        print self.category
        print self.event_type
        print self.details_link
        print self.location
        print self.description
        
    def load_details(self):
        pass
                
class OSUEvents(EventDetails):

    def load_details(self):
        html_doc = urllib2.urlopen(self.event_link).read()
        soup = BeautifulSoup(html_doc)

        event_details = soup.table.findAll("tr")
        for d in event_details:
            detail_title = d.findAll("td")[0].contents
            tds = d.findAll("td")[1].contents
            if detail_title[0] == "Event:":
                temp_str = ""
                for c in tds:
                    if len(c) > 0:
                        if isinstance(c,NavigableString)  == False and c.contents:
                            temp_str += str(c.contents[0])
                            continue
                        temp_str += "\n" +str(c)
                self.description = temp_str
                
            if detail_title[0] == "Date and time:" and len(tds) > 0:
                if len(tds) > 1:
                    start_time = re.findall(r'(.*) -', str(tds[2]))
                    end_time = re.findall(r'.* - (.*)', str(tds[2]))
                    if len(start_time) > 0: 
                        t = str(tds[0]) + " " + start_time[0]
                        try: 
                            self.start_date = datetime.strptime(t, "%B %d, %Y %I:%M %p")
                        except:
                            self.start_date = datetime.strptime(str(tds[0]), "%B %d, %Y")
                            
                    else:
                        t = str(tds[0]) + " " + str(tds[2])
                        self.start_date = datetime.strptime(t, "%B %d, %Y %I:%M %p")
                        
                    if len(end_time) > 0:                     
                        t = str(tds[0]) + " " + end_time[0]
                        self.end_date = datetime.strptime(t, "%B %d, %Y %I:%M %p")

                else:
                    self.start_date = datetime.strptime(tds[0], "%B %d, %Y") 
                
            if detail_title[0] == "Location:" and len(tds) == 1:
                #print tds[0]
                self.location = str(tds[0]).encode('utf-8')
                
            if detail_title[0] == "Phone Number:" and len(tds) == 1:
                self.contact_number = str(tds[0]).encode('utf-8')
                
            if detail_title[0] == "Event category:" and len(tds) == 1:
                self.category = str(tds[0]).encode('utf-8')
                
            if detail_title[0] == "Event Type:" and len(tds) == 1:
                self.event_type = str(tds[0]).encode('utf-8')                
                
            if detail_title[0] == "Contact:" and len(tds) == 1:
                if isinstance(tds[0],NavigableString)  == False : #tds[0]['href']:
                    self.contact_email = str(tds[0]['href'][7:]).encode('utf-8')
                    self.contact_name = str(tds[0].text).encode('utf-8')
