class User < ApplicationRecord
  ROLE = {
      employee: 1
  }

  validates_uniqueness_of :username

  def role
    ROLE.key?(type.downcase.to_sym) ? ROLE[type.downcase.to_sym] : super
  end
end
