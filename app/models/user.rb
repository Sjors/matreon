class User < ApplicationRecord
  before_create :initialize_contribution
  before_destroy :remove_contribution
  
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_one :contribution

  def initialize_contribution
    self.build_contribution(amount: 0)
  end

  def remove_contribution
    self.contribution.delete()
  end
end
