class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # validations
  validates :role, format: /user|admin/

  # relations
  belongs_to :account
  has_many :entries

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name

  JSON_FIELDS = [:id, :name, :email, :invitation_token]

  def active?
    # Comment out the below debug statement to view the properties of the returned self model values.
    # logger.debug self.to_yaml

    super && active && account.active
  end

  def safe_name
    name.nil? || name.empty? ? email : name
  end
end
