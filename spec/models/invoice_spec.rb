require "rails_helper"

RSpec.describe Contribution, :type => :model do
  fixtures :users, :invoices

  before do
    travel_to Time.zone.local(2018, 02, 15)
  end

  describe "email!" do
    it "should call the mailer" do
      expect { invoices(:alice_february).email! }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "should mark as emailed" do
      invoices(:alice_february).email!
      expect(invoices(:alice_february).emailed_at).not_to be_nil
    end
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

  describe "self.poll_unpaid!" do
    before do
    end

    it "should call poll! on unpaid invoice" do
      expect_any_instance_of(Invoice).to receive(:poll!).and_return true

      invoices(:dave_february).update status: 'unpaid', paid_at: nil
      Invoice.poll_unpaid!
    end

    it "should not call poll! on a paid invoice" do
      expect_any_instance_of(Invoice).not_to receive(:poll!).and_return true
      Invoice.poll_unpaid!
    end

    it "should not call poll! on an expired invoice" do
      expect_any_instance_of(Invoice).not_to receive(:poll!).and_return true
      invoices(:dave_february).update status: 'expired', paid_at: nil
      Invoice.poll_unpaid!
    end
  end

  describe "self.email_unpaid_once!" do
    before do
      invoices(:dave_february).update status: 'unpaid', paid_at: nil
    end

    it "should call email! on every invoice that's unpaid and unsent" do
      expect_any_instance_of(Invoice).to receive(:email!).and_return true
      Invoice.email_unpaid_once!
    end

    it "should not email about a paid invoice" do
      invoices(:dave_february).update status: 'paid', paid_at: Time.zone.local(2018, 02, 28)
      expect_any_instance_of(Invoice).not_to receive(:email!).and_return true
      Invoice.email_unpaid_once!
    end

    it "should not email about an invoice twice" do
      invoices(:dave_february).update emailed_at: Time.zone.local(2018, 02, 28)
      expect_any_instance_of(Invoice).not_to receive(:email!)
      Invoice.email_unpaid_once!
    end

    it "should not email if a Lightning Charge ID is missing" do
      invoices(:dave_february).update charge_invoice_id: nil
      expect_any_instance_of(Invoice).not_to receive(:email!)
      Invoice.email_unpaid_once!
    end
  end
end
