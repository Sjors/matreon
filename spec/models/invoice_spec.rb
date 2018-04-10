require "rails_helper"

RSpec.describe Contribution, :type => :model do
  fixtures :users, :invoices

  before do
    travel_to Time.new(2018, 02, 15)
  end

  describe "scope :this_month" do
    it "should only include invoices less than a month old" do
      expect(Invoice.this_month.length).to eq(1)
    end
  end

  describe "self.generate!" do
    before do
      allow_any_instance_of(Invoice).to receive(:create_lightning_charge_invoice)
    end

    it "should create an invoice one month after the last" do
      Invoice.generate!
      expect(Invoice.count).to eq(3)
      expect(Invoice.last.user).to eq(users(:carol))
    end
  end

  describe "self.email!" do
    it "should ..."
  end
end
