require "rails_helper"

RSpec.describe Contribution, :type => :model do
  fixtures :users, :contributions, :invoices

  before do
    travel_to Time.zone.local(2018, 02, 15)
  end

  describe "creation" do
    before do
      allow_any_instance_of(Invoice).to receive(:create_lightning_charge_invoice)
    end
  
    it "should set billing day of month to current day of month" do
      users(:alice).create_contribution(amount: 1)
      expect(users(:alice).contribution.billing_day_of_month).to eq(15)
    end

    it "should not set billing day higher than 28" do
      travel_to Time.zone.local(2018, 07, 31)
      users(:alice).create_contribution(amount: 1)
      expect(users(:alice).contribution.billing_day_of_month).to eq(28)
    end
  end

  describe "self.active_count" do
    before do
      allow_any_instance_of(Invoice).to receive(:create_lightning_charge_invoice)
    end

    it "should exlude 0 satoshi contributors" do
      expect(Contribution.active_count).to eq(2)
    end
  end

  describe "create_or_update_invoice!" do
    before do
      allow_any_instance_of(Invoice).to receive(:create_lightning_charge_invoice)
    end

    it "should create an invoice if the user doesn't have one yet" do
      contributions(:carol).create_or_update_invoice!
      expect(contributions(:carol).user.invoices.count).to eq(1)
    end

    it "should not create an invoice if the user already has one" do
      contributions(:carol).create_or_update_invoice!
      contributions(:carol).create_or_update_invoice!
      expect(contributions(:carol).user.invoices.count).to eq(1)
    end

    it "should replace the invoice if the user increased the amount" do
      contributions(:carol).create_or_update_invoice!
      contributions(:carol).update(amount: 2) # calls create_or_update_invoice! in before_save
      expect(users(:carol).invoices.count).to eq(1)
      expect(users(:carol).invoices.first.amount).to eq(2)
    end

    it "should create a new invoice on a billing day" do
      contributions(:carol).create_or_update_invoice!
      travel_to Time.zone.local(2018, 03, 15)
      contributions(:carol).create_or_update_invoice!
      expect(contributions(:carol).user.invoices.count).to eq(2)
    end
  end
end
