import urllib2
import re
import time
from datetime import date, timedelta, datetime
from BeautifulSoup import BeautifulSoup, NavigableString, Tag
from Events import OSUEvents
from sqlalchemy.orm import sessionmaker
from sqlalchemy import *


def get_osu_events(num_days, session):
    which_date = date.today()
    td = timedelta(days=1)
    for i in range(num_days):
        print which_date
        str_date = which_date.strftime('%Y-%m-%-d')
        print str_date
#        print date.strftime('%Y %2m %d', datetime.now())
#        print "%d-%2d-%d"%(which_date.year, which_date.month, which_date.day)
 #       break
        page_url = 'http://www.osu.edu/events/indexDay.php?Event_ID=&Date=' + str_date
        #print page_url
        html_doc = urllib2.urlopen(page_url).read()
        #print page_url
        #return
        soup = BeautifulSoup(html_doc)
        events = soup.table.contents[3].td.findAll("p")
        for e in events:
            event_name = e.contents[0].text    
            event_link = "http://www.osu.edu/events/" + str(e.contents[0]['href'])
            print event_link
            event = OSUEvents(event_name, event_link)
            event.load_details()
            #event.display()
            db_event = session.query(OSUEvents).filter_by(event_link=event.event_link).first() 
            if not db_event :
                print "Yes"
                session.add(event)
                session.commit()
            #print "\n"
        which_date = which_date + td

db = create_engine('mysql://root:tarun123@localhost/osu_events') 
Session = sessionmaker(bind=db)
db.echo = False
metadata = MetaData()
metadata.create_all(db)
session = Session()
get_osu_events(15, session)
