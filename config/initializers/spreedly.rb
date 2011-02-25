if Rails.env.test?
  require 'spreedly/mock'
else
  require 'spreedly'
end

Spreedly.configure("AoteaStudios-test", "***REMOVED***")
