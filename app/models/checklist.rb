class Checklist < ActiveRecord::Base
  has_many :items, :dependent => :destroy, :autosave => true
  has_many :entries
end
