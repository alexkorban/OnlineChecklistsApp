class Account < ActiveRecord::Base
  has_many :users, :autosave => true
end
