require 'rubygems'
require 'open-uri'
require 'json'
require 'hpricot'
require 'cgi'

def get_link_address(html_tag)
	regex = Regexp.new(/.*<a href="(.*)">.*/)
	sub_string = regex.match(html_tag.to_s)
	event_link = sub_string[1]
	event_link
end

def get_link_name(html_tag)
	regex = Regexp.new(/.*<a href.*>(.*)<\/a>.*/)
	sub_string = regex.match(html_tag.to_s)
	event_link = sub_string[1]
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

def get_event_description(html_tag)
	regex = Regexp.new(/.*<\/a>(.*)/)
	sub_string = regex.match(html_tag)
	event_link = ""
	if(sub_string != nil)
		event_link = sub_string[1]
	end
	event_link
end


	url = "http://www.osu.edu/events/indexDay.php?Event_ID=&Date=2011-11-1"
	doc = Hpricot(open(url)) 
	day = doc/"//td[@class=day]"
	events = day/"//p"
	events.map.each{|event| 
				eventHash = Hash.new()
				group_node = event/"//span[@class=group]"
				group = group_node.inner_html
				event_name_node = event/"//a"


				event_link = "http://www.osu.edu/events/" + get_link_address(event_name_node)
				puts event_link
				event_page = Hpricot(open(event_link))
#				puts event_page.to_s
				event_details_node = event_page/"//div[@id=event_info]"
				event_details_tr = event_details_node/"//tr"

				event_td = event_details_tr[0]/"//td"
				eventHash["name"] = get_link_name(event_td[1].inner_html.to_s)
				puts eventHash["name"]

				event_td = event_details_tr[0]/"//td"
				eventHash["actual_link"] = get_link_address(event_td[1].inner_html.to_s)
				puts eventHash["actual_link"]

				event_td = event_details_tr[0]/"//td"
				eventHash["description"] = get_event_description(event_td[1].inner_html.to_s)
				puts eventHash["description"]

				event_td = event_details_tr[1]/"//td"
				eventHash["date"] = get_date(event_td[1].inner_html.to_s)
				puts eventHash["date"]

				event_td = event_details_tr[1]/"//td"
				eventHash["time"] = get_time(event_td[1].inner_html.to_s)
				puts eventHash["time"]

				event_td = event_details_tr[2]/"//td"
				eventHash["location"] = event_td[1].inner_html.to_s
				puts eventHash["location"]

				event_td = event_details_tr[3]/"//td"
				eventHash["contact_email"] = get_email_address(event_td[1].inner_html.to_s)
				puts eventHash["contact_email"]

				event_td = event_details_tr[3]/"//td"
				eventHash["contact_name"] = get_contact_name(event_td[1].inner_html.to_s)
				puts eventHash["contact_name"]

				event_td = event_details_tr[4]/"//td"
				eventHash["contact_number"] = event_td[1].inner_html.to_s
				puts eventHash["contact_number"]

				event_td = event_details_tr[5]/"//td"
				eventHash["category"] = event_td[1].inner_html.to_s
				puts eventHash["category"]

				event_td = event_details_tr[6]/"//td"
				eventHash["type"] = event_td[1].inner_html.to_s
				puts eventHash["type"]
				puts " ________________________________________________"
			}



