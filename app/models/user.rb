class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable
  include DeviseTokenAuth::Concerns::User
  has_many :fcm_tokens

  belongs_to :organization

  ROLE = {
      employee: 1,
      manager: 2
  }

  validates_uniqueness_of :username

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def role
    ROLE.key?(type.downcase.to_sym) ? ROLE[type.downcase.to_sym] : super
  end

  def is_manager?
    self.type == "Manager"
  end

  def as_json(*args)
    hash = super(*args)
    hash.merge({manager: is_manager?, organization_name: self.organization.name, organization_id: self.organization_id})
  end


end
