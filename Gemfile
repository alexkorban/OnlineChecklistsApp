source 'http://rubygems.org'

gem 'rails', '3.0.5'
gem "haml", "3.0.25"
gem 'pg', "0.10.1"
gem "devise", "1.1.7"
gem "devise_invitable", "0.3.6"
gem "spreedly", "1.3.4", require: false   # don't require automatically because we need to require spreedly/mock in the test env
gem "delayed_job", "2.1.4"
gem "hoptoad_notifier", "2.4.6"
# TODO: specify versions; right_aws 2.0.0 isn't compatible with Rails, so I had to use the latest version
# of right_aws along with its dependency right_http_connection; in the future it should be enough to just specify
# right_aws 2.0.1 (or whatever version works) and drop right_http_connection declaration
gem "right_http_connection", git: "git://github.com/rightscale/right_http_connection.git"
gem "right_aws", git: "git://github.com/rightscale/right_aws.git"
gem "heroku_backup_task", "0.0.4"

group :development do
  gem 'hpricot'
  gem 'ruby_parser'
end

group :test do
  gem 'test-unit'
  gem 'machinist', '>= 2.0.0.beta1'
end

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
