if Rails.env.test?
  require 'spreedly/mock'
else
  require 'spreedly'
end

Spreedly.configure("AoteaStudios-test", "***REMOVED***")

# this should only be done for testing
#class Spreedly::Subscriber
#  attr_accessor :data
#end
