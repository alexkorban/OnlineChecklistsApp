class Checklist < ActiveRecord::Base
  has_many :items, :dependent => :destroy, :autosave => true
end
