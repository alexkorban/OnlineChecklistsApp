if Rails.env.test?
  require 'spreedly/mock'
else
  require 'spreedly'
end

if Rails.env.staging?
  Spreedly.configure("OnlineChecklists-staging", "***REMOVED***")
elsif Rails.env.production?
  Spreedly.configure("OnlineChecklists", "***REMOVED***")
else
  #Spreedly.configure("OnlineChecklists-paytest", "***REMOVED***")
  Spreedly.configure("OnlineChecklists-dev", "***REMOVED***")
end

# this should only be done for testing
#class Spreedly::Subscriber
#  attr_accessor :data
#end
