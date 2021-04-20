class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable
  include DeviseTokenAuth::Concerns::User
  has_many :fcm_tokens
  validate :validate_username

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

  def manager?
    self.type == "Manager"
  end

  def as_json(*args)
    hash = super(*args)
    hash.merge({manager: manager?, organization_name: self.organization.name, organization_id: self.organization_id})
  end

  def validate_username
    unless self.username.match?(/[A-z0-9]+([A-z0-9.]).([A-z0-9]+)+/)
      errors.add(:username, "username does not match pattern")
    end
  end

end
