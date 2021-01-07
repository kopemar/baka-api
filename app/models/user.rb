class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable
  include DeviseTokenAuth::Concerns::User

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

  def is_manager
    self.type == "Manager"
  end

  def as_json(*args)
    hash = super(*args)
    hash.merge(manager: is_manager)
  end
end
