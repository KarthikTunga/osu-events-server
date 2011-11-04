%w(rubygems yaml pg active_record).each do |lib| require lib end

app_root = ENV['WEBSERVER_ROOT']
  
dbconfig = YAML::load(File.open("#{app_root}/config/database.yml"))["dev"]

puts "DBCONFIG: #{dbconfig.inspect}"
conn = ActiveRecord::Base.establish_connection(dbconfig)
puts "DB CONNECTION: #{conn.inspect}"
