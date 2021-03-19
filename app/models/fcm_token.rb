class FcmToken < ApplicationRecord
  belongs_to :user

  upsert_keys [:client]
end
