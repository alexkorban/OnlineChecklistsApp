class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # defaults
  default_scope :order => 'name'

  # validations
  validates :role, format: /user|admin/

  # relations
  belongs_to :account
  has_many :entries

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name

  # callbacks
  #before_create {|user| user.account = current_user.account }
end
