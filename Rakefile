# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

OnlineChecklistsApp::Application.load_tasks

namespace :heroku do
  desc "PostgreSQL database backups from Heroku to Amazon S3"
  task :s3backup => :environment do
    begin
      require 'right_aws'
      puts "[#{Time.now}] heroku:s3backup started"

      name = "#{ENV['APP_NAME']}-#{Time.now.strftime('%Y-%m-%d-%H%M%S')}.dump"

      db = ENV['DATABASE_URL'].match(/postgres:\/\/([^:]+):([^@]+)@([^\/]+)\/(.+)/)

      system "PGPASSWORD=#{db[2]} pg_dump -Fc --username=#{db[1]} --host=#{db[3]} #{db[4]} > tmp/#{name}"

      s3 = RightAws::S3.new(ENV['s3_access_key_id'], ENV['s3_secret_access_key'])

      bucket = s3.bucket("#{ENV['APP_NAME']}-heroku-backups", true, 'private')

      bucket.put(name, open("tmp/#{name}"))

      system "rm tmp/#{name}"

      puts "[#{Time.now}] heroku:s3backup complete"
    rescue Exception => e
      puts "there was an exception #{e}"
      HoptoadNotifier.notify(:error_class => "heroku:s3backup error", :error_message => "heroku:s3backup error: #{e.message}")
      # rescue Exception => e
      # require 'toadhopper'
      # Toadhopper(ENV['hoptoad_key']).post!(e)
    end
  end
end

require "heroku_backup_task"
task :cron => :environment do
  HerokuBackupTask.execute
  Rake::Task['heroku:s3backup'].invoke
end


task :insert_demo_data => :environment do
  account = Account.find 4

  mark = User.find_by_name "Mark"
  michelle = User.find_by_name "Michelle"
  admin = User.find_by_name "Admin"

  phone_sale_cl = Checklist.find_by_name "Phone sale key points"
  packing_cl = Checklist.find_by_name "Product mail-out packing"
  new_hire_cl = Checklist.find_by_name "New employee orientation"
  safety_cl = Checklist.find_by_name "Workplace safety"

  names = ["Connor Leblanc",
           "David Goff",
           "Paki Estrada",
           "Dexter Mcconnell",
           "Zeph Morin",
           "Dante Marquez",
           "Zahir Hampton",
           "Yuli Baldwin",
           "Hiram Ellison",
           "Castor Bass",
           "Craig Leach",
           "Ryder Mcneil",
           "Ross Howell",
           "Ivan Rasmussen",
           "Baker Craft",
           "Fletcher Fuentes",
           "Oleg Mills",
           "Mark Kaufman",
           "Tiger Webb",
           "Ashton Terrell",
           "Knox George",
           "Hiram Mccray",
           "Neville Horne",
           "Leo Christian",
           "Neil Rowland",
           "Cody Watson",
           "Elmo Becker",
           "Kaseem Casey",
           "Jared Bates",
           "Timothy Mcdonald",
           "Damon Ellison",
           "Tobias Wright",
           "Theodore Maxwell",
           "Igor Ross",
           "Jesse Macdonald",
           "Moses Burns",
           "Tarik Carson",
           "Nehru Mckenzie",
           "Kirk Garner",
           "Prescott Franco",
           "Brennan Wynn",
           "Damon Hudson",
           "Amos Santana",
           "Lance Mann",
           "Solomon Lambert",
           "Byron Burks",
           "Quamar Becker",
           "Blake Norton",
           "Lewis Mcdonald",
           "Hunter Cash",
           "Bruno Chapman",
           "Demetrius Baird",
           "Edan Woodard",
           "Lewis Tyson",
           "Eagan Heath",
           "Coby Hoover",
           "Giacomo Jenkins",
           "Thane Howe",
           "Dieter Kirby",
           "Abraham Carver",
           "Adrian Castro",
           "Dean Roth",
           "Clinton Hanson",
           "Hyatt Simon",
           "Xavier Washington",
           "Abbot Burgess",
           "Blaze Farrell",
           "Burton Hodges",
           "Darius Roberson",
           "Eric Mcbride",
           "Cedric Maddox",
           "Ahmed Mccarty",
           "Alec Valdez",
           "Alec Fulton",
           "Griffith Barnett",
           "Hunter Holder",
           "Charles Quinn",
           "Colt Herrera",
           "Brent Parker",
           "Dante Brock",
           "Lyle Edwards",
           "Colby Reyes",
           "Joshua Guerrero",
           "Chaim Salas",
           "Burton Leblanc",
           "Garrison Gates",
           "Barclay Hebert",
           "Trevor Buckner",
           "Edward Warner",
           "Harper Potts",
           "Yoshio Trevino",
           "Calvin Cline",
           "Macon Hatfield",
           "Kirk Robinson",
           "Benjamin Snow",
           "Tanner Randall",
           "Branden Bruce",
           "Jarrod Nelson",
           "Ignatius Pacheco",
           "Hu Miles"]

  # Mark: Phone sale: 3-7 per day; Packing: 1-5 per day
  # Michelle: Phone sale: 2-9 per day; Packing: 3-5 per day
  # 9-5, weekdays only, over a period of 6 weeks

  # Admin: 1 new hire, 2 workplace safety over 6 weeks

  0.upto(6 * 7) {|n|
    workday_start = (Time.zone.now - n.days).beginning_of_day + 9.hours
    
    # Mark's entries
    1.upto(3 + rand(5)) {
      entry_time = workday_start + rand(8).hours + rand(60).minutes
      Entry.create(:account_id => account.id, :user_id => mark.id, :checklist_id => phone_sale_cl.id, :created_at => entry_time, :notes => names[rand(99)])
    }
    1.upto(1 + rand(5)) {
      entry_time = workday_start + rand(8).hours + rand(60).minutes
      Entry.create(:account_id => account.id, :user_id => mark.id, :checklist_id => packing_cl.id, :created_at => entry_time, :notes => names[rand(99)])
    }
    # Michelle's entries
    1.upto(2 + rand(8)) {
      entry_time = workday_start + rand(8).hours + rand(60).minutes
      Entry.create(:account_id => account.id, :user_id => michelle.id, :checklist_id => phone_sale_cl.id, :created_at => entry_time, :notes => names[rand(99)])
    }
    1.upto(3 + rand(3)) {
      entry_time = workday_start + rand(8).hours + rand(60).minutes
      Entry.create(:account_id => account.id, :user_id => michelle.id, :checklist_id => packing_cl.id, :created_at => entry_time, :notes => names[rand(99)])
    }
  }

  # Admin's entries
  entry_time = (Time.zone.now - rand(30).days).beginning_of_day + 9.hours + rand(8).hours + rand(60).minutes
  Entry.create(:account_id => account.id, :user_id => admin.id, :checklist_id => new_hire_cl.id, :created_at => entry_time)

  entry_time = (Time.zone.now - rand(30).days).beginning_of_day + 9.hours + rand(8).hours + rand(60).minutes
  Entry.create(:account_id => account.id, :user_id => admin.id, :checklist_id => safety_cl.id, :created_at => entry_time)
  entry_time = (Time.zone.now - rand(30).days).beginning_of_day + 9.hours + rand(8).hours + rand(60).minutes
  Entry.create(:account_id => account.id, :user_id => admin.id, :checklist_id => safety_cl.id, :created_at => entry_time)

end