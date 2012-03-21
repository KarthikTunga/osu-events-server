require 'rubygems'
require 'open-uri'
require 'sinatra'
require 'json'
require 'net/https'
require 'cgi'

get '/test' do
	headers({"Content-Type" => "text/html; charset=ISO-8859-1"})
	erb("hello")
end

get '/fb' do
    http = Net::HTTP.new('graph.facebook.com', 443)
    http.use_ssl = true
    path = '/885010384/friends?access_token=AAAFMmFSEZCykBAB4iWKSuLrfcqgvozBFn8uLxPaolVSMhuVtZCJZAPszqMQjZCDOvAxmWXWAnDvJpCQto436Q6cmtJwq5YFVXhz4617ZCWAZDZD'

    # GET request -> so the host can set his cookies
    resp, data = http.get(path, nil)
    puts data
    res = JSON.parse(data)
    res["data"].map { |v| 
        puts v["id"]
    }
end
