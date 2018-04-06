class Contribution < ApplicationRecord
  belongs_to :user

  def as_json(options = nil)
    super({ only: [:amount] }.merge(options || {}))
  end

  def self.active_count
    # TODO: exclude contributors more than 1 month behind in payments
    return self.where('amount > ?', 1).count
  end
end
