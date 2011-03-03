class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # validations
  validates :role, format: /user|admin/
  validates :account_id, presence: true, numericality: true
  validates :email, presence: true

  # relations
  belongs_to :account
  has_many :entries

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name

  JSON_FIELDS = [:id, :name, :email, :invitation_token, :role]

  # this will be used during authentication by Devise
  def active?
    # Comment out the below debug statement to view the properties of the returned self model values.
    #logger.debug self.to_yaml

    super && active && account.active
  end

  def self.active
    where active: true
  end

  # returns the user's name or email if name isn't present
  def safe_name
    name.nil? || name.empty? ? email : name
  end

  def password_required?
    return false if invitation_token.nil? || invitation_token.empty?
    super
  end
end
