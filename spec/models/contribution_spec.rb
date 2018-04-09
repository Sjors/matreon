require "rails_helper"

RSpec.describe Contribution, :type => :model do
  fixtures :users

  describe "self.active_count" do
    before do
      allow_any_instance_of(Invoice).to receive(:create_lightning_charge_invoice)
    end

    it "should exlude 0 satoshi contributors" do
      users(:alice).create_contribution(amount: 1)
      users(:bob).create_contribution(amount: 0)
      expect(Contribution.active_count).to eq(1)
    end
  end
end
