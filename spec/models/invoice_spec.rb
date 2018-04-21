require "rails_helper"

RSpec.describe Contribution, :type => :model do
  fixtures :users, :invoices

  before do
    travel_to Time.zone.local(2018, 02, 15)
  end

  describe "self.generate!" do
    before do
      allow_any_instance_of(Invoice).to receive(:create_lightning_charge_invoice)
    end

    it "should not create an invoice on non-billing day" do
      expect(users(:dave).invoices.count).to eq(2) # Fixtures
      travel_to Time.zone.local(2018, 03, 14)
      Invoice.generate!
      expect(users(:dave).invoices.count).to eq(2)
    end

    it "should create an invoice on billing day" do
      travel_to Time.zone.local(2018, 03, 15)
      Invoice.generate!
      expect(users(:dave).invoices.count).to eq(3)
    end
  end

  describe "self.email!" do
    it "should ..."
  end
end
