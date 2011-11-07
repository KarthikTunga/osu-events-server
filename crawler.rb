require 'rubygems'
require 'open-uri'
require 'json'
require 'hpricot'
require 'cgi'
require 'time'
require 'date'
require 'active_record'
require 'models'

load 'db/db_connect.rb'


def get_link_address(html_tag)
	event_link = nil
	regex = Regexp.new(/.*<a href="(.*)">.*/)
	sub_string = regex.match(html_tag.to_s)
	if(sub_string != nil)
		event_link = sub_string[1]
	end
	event_link
end

def get_link_name(html_tag)
	event_link = nil
	regex = Regexp.new(/.*<a href.*>(.*)<\/a>.*/)
	sub_string = regex.match(html_tag.to_s)
	if(sub_string != nil)
		event_link = sub_string[1]
	end
	event_link
end

def get_email_address(html_tag)
	regex = Regexp.new(/.*<a href="mailto:(.*)">.*/)
	sub_string = regex.match(html_tag)
	event_link = sub_string[1]
	event_link
end

def get_contact_name(html_tag)
	regex = Regexp.new(/.*<a href="mailto:.*">(.*)<.*/)
	sub_string = regex.match(html_tag)
	event_link = sub_string[1]
	event_link
end

def get_date(html_tag)
	regex = Regexp.new(/(.*)<br.*/)
	sub_string = regex.match(html_tag)
	event_link = sub_string[1]
	event_link
end

def get_time(html_tag)
	regex = Regexp.new(/.*<br \/>(.*)/)
	sub_string = regex.match(html_tag)
	event_link = sub_string[1]
	event_link
end


def get_start_time(html_tag, date)
	regex = Regexp.new(/(.*) - /)
	sub_string = regex.match(html_tag)
	event_link = html_tag
	if(sub_string != nil)
		event_link = sub_string[1]
	end
#	event_link
	full_time = date + " " + event_link
	#Time.parse(full_time)
	puts (DateTime.parse(full_time)).to_s
	(DateTime.parse(full_time))
end


def get_end_time(html_tag, date)
	regex = Regexp.new(/.*- (.*)/)
	sub_string = regex.match(html_tag)
	event_link = html_tag
	if(sub_string != nil)
		event_link = sub_string[1]
	end
#	event_link

	full_time = date + " " + event_link
	puts (Time.parse(full_time)).to_s
	(Time.parse(full_time))
end

def get_event_description(html_tag)
	regex = Regexp.new(/.*<\/a>(.*)/)
	sub_string = regex.match(html_tag)
	event_link = ""
	if(sub_string != nil)
		event_link = sub_string[1]
	end
	ic = Iconv.iconv('utf-8', 'macintosh', event_link) 
	ic
end

def clean_events_osu_edu_events(events)
	eventsArray = Array.new()
	events.map.each{|event| 
		eventHash = Hash.new()
		group_node = event/"//span[@class=group]"
		group = group_node.inner_html
		event_name_node = event/"//a"


		event_link = "http://www.osu.edu/events/" + get_link_address(event_name_node)
		eventHash["name"] = get_link_name(event_name_node)
		puts eventHash["name"]
		eventHash["event_link"] = event_link
		#puts event_link
		event_page = Hpricot(open(event_link))
#				#puts event_page.to_s
		event_details_node = event_page/"//div[@id=event_info]"
		event_details_tr = event_details_node/"//tr"

		event_td = event_details_tr[0]/"//td"

#		eventHash["name"] = get_link_name(event_td[1].inner_html.to_s) 
#		if eventHash["name"] == nil
		#puts eventHash["name"]

		event_td = event_details_tr[0]/"//td"
		eventHash["details_link"] = get_link_address(event_td[1].inner_html.to_s)
		#puts eventHash["actual_link"]

		event_td = event_details_tr[0]/"//td"
		eventHash["description"] = get_event_description(event_td[1].inner_html.to_s)
		#puts eventHash["description"]

		event_td = event_details_tr[1]/"//td"
		eventHash["date"] = get_date(event_td[1].inner_html.to_s)
		#puts eventHash["date"]

		event_td = event_details_tr[1]/"//td"
		full_time= get_time(event_td[1].inner_html.to_s)
		eventHash["start_time"] = get_start_time(full_time, eventHash["date"])
		#puts eventHash["start_time"]

		event_td = event_details_tr[1]/"//td"
		full_time= get_time(event_td[1].inner_html.to_s)
		eventHash["end_time"] = get_end_time(full_time, eventHash["date"])
		#puts eventHash["end_time"]

		event_td = event_details_tr[2]/"//td"
		eventHash["location"] = event_td[1].inner_html.to_s
		#puts eventHash["location"]

		event_td = event_details_tr[3]/"//td"
		eventHash["contact_email"] = get_email_address(event_td[1].inner_html.to_s)
		#puts eventHash["contact_email"]

		event_td = event_details_tr[3]/"//td"
		eventHash["contact_name"] = get_contact_name(event_td[1].inner_html.to_s)
		#puts eventHash["contact_name"]

		event_td = event_details_tr[4]/"//td"
		eventHash["contact_number"] = event_td[1].inner_html.to_s
		#puts eventHash["contact_number"]

		event_td = event_details_tr[5]/"//td"
		eventHash["category"] = event_td[1].inner_html.to_s
		#puts eventHash["category"]

		event_td = event_details_tr[6]/"//td"
		eventHash["event_type"] = event_td[1].inner_html.to_s
		puts eventHash["event_type"]
		eventsArray.push(eventHash)
	}

	eventsArray
end

def get_events_for_date(date)
	url = "http://www.osu.edu/events/indexDay.php?Event_ID=&Date="+date
	puts url
	doc = Hpricot(open(url)) 
	day = doc/"//td[@class=day]"
	events = day/"//p"
	clean_events_osu_edu_events(events)
end


ARGV[0].to_i.times { |i|
#	date = (Date.today + i).to_s.gsub(" ","")
	date = (Date.today + i).strftime("%Y-%m-%e").gsub(" ","")

	puts date
	events = get_events_for_date(date)
	events.map.each{ |event|
			Events.create(:name => event["name"], :start_date => event["start_date"], :end_date => event["end_date"], 
				:contact_email => event["contact_email"], :contact_name => event["contact_name"], 
				:contact_number => event["contact_number"], :category => event["category"], :event_type => event["event_type"], 
				:description => event["description"], :event_link => event["event_link"], :details_link => event["details_link"], 
				:location => event["location"])
	}
}
