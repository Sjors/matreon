require "rails_helper"

RSpec.describe Contribution, :type => :model do
  describe "creation" do
    it "should set billing day of month to current day of month" do
      travel_to Time.zone.local(2018, 2, 15)
      contribution = create(:contribution, amount: 1)
      expect(contribution.billing_day_of_month).to eq(15)
    end

    it "should not set billing day higher than 28" do
      travel_to Time.zone.local(2018, 7, 31)
      contribution = create(:contribution, amount: 1)
      expect(contribution.billing_day_of_month).to eq(28)
    end
  end
  
  describe "subscribed_up_to" do
    let!(:contribution) do
      travel_to Time.zone.local(2018, 2, 15) do
        create(:contribution, amount: 0)
      end
    end

    before do
      travel_to Time.zone.local(2018, 2, 15)
    end

    it "should return something long ago for users without invoices" do
      contribution.update!(amount: 0)
      expect(contribution.subscribed_up_to).to eq(Time.zone.local(2000, 1, 1) )
    end
    
    it "should return something long ago for users with no paid invoices" do
      contribution.update!(amount: 1)
      expect(contribution.subscribed_up_to).to eq(Time.zone.local(2000, 1, 1) )
    end
    
    it "should return 1 month after the last paid invoice" do
      contribution.update!(amount: 1)
      travel_to Time.zone.local(2018, 2, 1)
      create(:invoice, :paid, user: contribution.user)
      contribution.reload
      expect(contribution.subscribed_up_to).to eq(Time.zone.local(2018, 3, 1) )
    end
  end

  describe "self.active_count" do
    before do
      create(:contribution, amount: 0)
      create(:contribution, amount: 1)
      create(:contribution, amount: 2)
    end

    it "should exlude 0 satoshi contributors" do
      expect(Contribution.active_count).to eq(2)
    end
  end

  describe "create_or_update_invoice!" do
    let!(:contribution) do
      travel_to Time.zone.local(2018, 2, 15) do
        create(:contribution)
      end
    end

    it "should create an invoice if the user doesn't have one yet" do
      contribution.create_or_update_invoice!

      expect(contribution.user.invoices.count).to eq(1)
    end

    it "should not create an invoice if the user already has one" do
      contribution.create_or_update_invoice!
      contribution.create_or_update_invoice!

      expect(contribution.user.invoices.count).to eq(1)
    end

    it "should replace the invoice if the user increased the amount" do
      contribution.create_or_update_invoice!
      contribution.update!(amount: 2)
      contribution.create_or_update_invoice!

      expect(contribution.user.invoices.count).to eq(1)
      expect(contribution.user.invoices.first.amount).to eq(2)
    end

    it "should create a new invoice on a billing day" do
      contribution.create_or_update_invoice!
      travel_to Time.zone.local(2018, 3, 15)
      contribution.create_or_update_invoice!

      expect(contribution.user.invoices.count).to eq(2)
    end
  end
end
