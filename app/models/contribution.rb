class Contribution < ApplicationRecord
  belongs_to :user

  def as_json(options = nil)
    super({ only: [:amount] }.merge(options || {}))
  end
end
