class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable
  include DeviseTokenAuth::Concerns::User

  ROLE = {
      employee: 1
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
end
