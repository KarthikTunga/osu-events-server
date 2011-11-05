%w(rubygems yaml pg active_record).each do |lib| require lib end

VERSION = ARGV[0] ? ARGV[0].to_i : nil

puts "Migrating to VERSION: #{VERSION.to_s}" if not VERSION.nil?

puts 'Starting Migrations'
load 'db_connect.rb'

#ActiveRecord::Base.colorize_logging = false
#logFile = File.open("database.log", "w") 
#ActiveRecord::Base.logger = Logger.new(logFile)

puts "ABOUT TO RUN MIGRATIONS"
#ActiveRecord::Migrator.migrate("migrations")

ActiveRecord::Migrator.migrate("migrations", VERSION )
