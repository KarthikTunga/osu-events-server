require 'rubygems'
require 'open-uri'
require 'sinatra'
require 'json'
require 'hpricot'
require 'cgi'
#require 'iconv'
get '/tarunrs/events' do
	url = "http://www.osu.edu/events/indexDay.php?Event_ID=&Date=2011-11-1"
	doc = Hpricot(open(url)) 
	day = doc/"//td[@class=day]"
	events = day/"//p"
	events.map.each{|event| 
				group_node = event/"//span[@class=group]"
				group = group_node.inner_html
				event_name_node = event/"//a"
				#event_link = event_name_node[0]
				#event_link = doc.search(a[@href*=event])
#				puts event_name_node.to_s
					regex = Regexp.new(/.*<a href="(.*)">.*/)
						#new(/.*Rated (.*) out of.*/)
					sub_string = regex.match(event_name_node.to_s)
					event_link = sub_string[1]
				event_link = "http://www.osu.edu/events/" + event_link
				event_page = Hpricot(open(event_link))
#				puts event_page.to_s
				event_details_node = event_page/"//div[@id=event_info]"
				event_details_tr = event_details_node/"//tr"
				event_details_tr.map.each{ |details|
					event_details_td = details/"//td"
					event_details_td.map.each{ |detail|
						puts "   "+ detail.inner_html.to_s
					}
				}
				puts ""
				event_name = event_name_node.inner_html
				puts event_name.to_s
				puts event_link.to_s
				puts group.to_s
				#puts event_details_node
			}

end
get '/tarunrs/movies' do
	listing = []
	flag =1
	i=0
	while flag == 1
		url = "http://www.google.com/movies?near="+CGI::escape(params[:city])+"&sort=1&start="+(i*10).to_s+"&date="+params[:date]
		#url = "http://www.google.com/movies?near="+CGI::escape(params[:city])+"&sort=1&start="+(i*10).to_s
		current_date = "-"
		doc = Hpricot(open(url))
		title_bar = doc/"//h1[@id=title_bar]"
		#ic = Iconv.new('US-ASCII//IGNORE', 'UTF-8')

		location = title_bar.to_s.gsub(/<\/?[^>]*>/, "");
#		location = ic.iconv(location ).pop
#		location = ic.iconv(location + ' ')[0..-2]

		left_nav =  doc/"//div[@id=left_nav]"
		sections = left_nav/"//div[@class=section]"
		days = sections[1]/"//div"
		days.map.each {|section| 
				ttd = section.at("b")
				dat = ttd.to_s.gsub(/<\/?[^>]*>/, "");
#				dat = Iconv.iconv('US-ASCII//IGNORE', 'UTF-8', dat).pop
#				dat = ic.iconv(dat + ' ')[0..-2]
				dats = dat.to_s.gsub("&rsaquo; ","")
				dats = dats.strip
				if (dats != nil and !dats.empty?)
					current_date = dats
				end
			}


		links = doc/"//div[@class=movie]"
		if(!links.empty?)

			links.map.each {|link| 
				header = link/"//div[@class=desc]"
				movie = Hash.new()
				#movie["name"] = Iconv.iconv('US-ASCII//IGNORE', 'UTF-8', header.at("a").inner_html).pop.gsub("&nbsp;","").gsub("&amp;","&").gsub("&#39;","'")
				movie["name"] = header.at("a").inner_html.gsub("&nbsp;","").gsub("&amp;","&").gsub("&#39;","'")
				movie["rating"] = header.at("img")
				if(movie["rating"]!= nil)
					regex = Regexp.new(/.*Rated (.*) out of.*/)
					sub_string = regex.match( movie["rating"].to_s)
					 movie["rating"] = sub_string[1]
				end
				movie["theaters"] = Array.new()

				theaters = link/"//div[@class=theater]"
				theaters.map.each {|theater|
						name = theater/"//div[@class=name]"
						showtimes = theater/"//div[@class=times]"
						theaterHash = Hash.new()
#						theaterHash["name"] = Iconv.iconv('US-ASCII//IGNORE', 'UTF-8',theater.at("a").inner_html).pop.gsub("&nbsp;","").gsub("&amp;","&").gsub("&#39;","'")
#						theaterHash["name"]  = ic.iconv(theater.at("a").inner_html + ' ')[0..-2].gsub("&nbsp;","").gsub("&amp;","&").gsub("&#39;","'")
						theaterHash["name"]  = theater.at("a").inner_html.gsub("&nbsp;","").gsub("&amp;","&").gsub("&#39;","'")
						theaterHash["times"] = showtimes.inner_html.gsub("&nbsp;","").gsub("&amp;","&").gsub(/<\/?[^>]*>/, "")

#						theaterHash["times"] = Iconv.iconv('US-ASCII//IGNORE', 'UTF-8', showtimes.inner_html).pop.gsub("&nbsp;","").gsub("&amp;","&").gsub(/<\/?[^>]*>/, "")
						movie["theaters"].push(theaterHash)
						}
				listing.push(movie)
				}
			i=i+1
		else
			flag =0
		end
	end
	listing = listing.sort_by{|listt| listt["name"]}
	headers({"Content-Type" => "text/html; charset=ISO-8859-1"})
	{"result" => {"date" => current_date, "listing" => listing, "location" => location}}.to_json

end

get '/tarunrs/theaters' do
	listing = []
	flag =1
	i=0
	while flag == 1
		url = "http://www.google.com/movies?near="+CGI::escape(params[:city])+"&start="+(i*10).to_s+"&date="+params[:date]
		current_date = "-"
		doc = Hpricot(open(url))
		title_bar = doc/"//h1[@id=title_bar]"
#		ic = Iconv.new('US-ASCII//IGNORE', 'UTF-8')
		location = title_bar.to_s.gsub(/<\/?[^>]*>/, "");
		#location = Iconv.iconv('US-ASCII//IGNORE', 'UTF-8', location).pop
#		location = ic.iconv(location + ' ')[0..-2]

		left_nav =  doc/"//div[@id=left_nav]"
		sections = left_nav/"//div[@class=section]"
		days = sections[1]/"//div"
		days.map.each {|section| 
				ttd = section.at("b")
				dat = ttd.to_s.gsub(/<\/?[^>]*>/, "");
#				dat = Iconv.iconv('US-ASCII//IGNORE', 'UTF-8', dat).pop
#				dat = ic.iconv(dat + ' ')[0..-2]
				dats = dat.to_s.gsub("&rsaquo; ","")
				dats = dats.strip
				if (dats != nil and !dats.empty?)
					current_date = dats
				end
			}

		links = doc/"//div[@class=theater]"
		if(!links.empty?)

			links.map.each {|link| 
				header = link/"//div[@class=desc]"
				theaterList = Hash.new()
#				theaterList["name"] = Iconv.iconv('US-ASCII//IGNORE', 'UTF-8', header.at("h2").inner_html).pop.gsub("&nbsp;","").gsub("&amp;","&").gsub("&#39;","'").to_s.gsub(/<\/?[^>]*>/, "")

				theaterList["name"] = header.at("h2").inner_html.gsub("&nbsp;","").gsub("&amp;","&").gsub("&#39;","'").to_s.gsub(/<\/?[^>]*>/, "")
				theaterList["movies"] = Array.new()
				movies = link/"//div[@class=movie]"
				movies.map.each {|movie|
						name = movie/"//div[@class=name]"
						showtimes = movie/"//div[@class=times]"				
						movieHash = Hash.new()
						movieHash["rating"] = movie.at("img")
						if(movieHash["rating"]!= nil)
							regex = Regexp.new(/.*Rated (.*) out of.*/)
							sub_string = regex.match( movieHash["rating"].to_s)
							movieHash["rating"] = sub_string[1]
						end
#						movieHash["name"] = ic.iconv('US-ASCII//IGNORE', 'UTF-8',movie.at("a").inner_html).pop.gsub("&nbsp;","").gsub("&amp;","&").gsub("&#39;","'")
#						movieHash["name"] = ic.iconv(movie.at("a").inner_html + ' ')[0..-2]..gsub("&nbsp;","").gsub("&amp;","&").gsub("&#39;","'")
#						movieHash["times"] = Iconv.iconv('US-ASCII//IGNORE', 'UTF-8', showtimes.inner_html).pop.gsub("&nbsp;","").gsub("&amp;","&").gsub(/<\/?[^>]*>/, "")
						movieHash["name"] = movie.at("a").inner_html.gsub("&nbsp;","").gsub("&amp;","&").gsub("&#39;","'")
						movieHash["times"] = showtimes.inner_html.gsub("&nbsp;","").gsub("&amp;","&").gsub(/<\/?[^>]*>/, "")

						theaterList["movies"].push(movieHash)
						}
				listing.push(theaterList)
				}
			i=i+1
		else
			flag =0
		end
	end
	listing = listing.sort_by{|listt| listt["name"]}
	headers({"Content-Type" => "text/html; charset=ISO-8859-1"})
	{"result" => {"date" => current_date, "listing" => listing, "location" => location}}.to_json

end


get '/test' do
	headers({"Content-Type" => "text/html; charset=ISO-8859-1"})
	erb("hello")
end


