class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable

  # validations
  validates :role, format: /user|admin/
  #validates :account_id, presence: true, numericality: true
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
  protected :password_required?

  # bypasses Devise's requirement to re-enter current password to edit
  def update_with_password(params={})
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end
    res = update_attributes(params)
    clean_up_passwords
    result
  end

  # override the default version in Timeoutable to make it play nicely with Rememberable
  def timedout?(last_access)
    return false if remember_exists_and_not_expired?
    super
  end

  def remember_exists_and_not_expired?
    return false unless respond_to?(:remember_expired?)
    remember_created_at && !remember_expired?
  end
  private :remember_exists_and_not_expired?

end
