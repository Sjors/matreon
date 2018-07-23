require "rails_helper"

RSpec.describe Contribution, :type => :model do
  let!(:user) { contribution.user }
  let!(:contribution) do
    travel_to Time.zone.local(2018, 1, 15) do
      create(:contribution)
    end
  end
  let!(:previous_invoice) do
    travel_to Time.zone.local(2018, 1, 15) do
      create(:invoice, :paid, user: user)
    end
  end
  let!(:latest_invoice) do
    travel_to Time.zone.local(2018, 2, 15) do
      create(:invoice, :paid, user: user)
    end
  end

  describe "email!" do
    let!(:unpaid_invoice) { create(:invoice, :unpaid) }

    it "should call the mailer" do
      expect { unpaid_invoice.email! }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "should mark as emailed" do
      unpaid_invoice.email!
      expect(unpaid_invoice.emailed_at).not_to be_nil
    end
  end

  describe "self.generate!" do
    it "should not create an invoice on non-billing day" do
      expect(user.invoices.count).to eq(2)
      travel_to Time.zone.local(2018, 03, 14) do
        Invoice.generate!
      end
      expect(user.invoices.count).to eq(2)
    end

    it "should create an invoice on billing day" do
      travel_to Time.zone.local(2018, 03, 15) do
        Invoice.generate!
      end
      expect(user.invoices.count).to eq(3)
    end
  end

  describe "self.poll_unpaid!" do
    it "should call poll! on unpaid invoice" do
      expect_any_instance_of(Invoice).to receive(:poll!).and_return true
      invoice = create(:invoice, :unpaid)
      Invoice.poll_unpaid!
    end

    it "should not call poll! on a paid invoice" do
      expect_any_instance_of(Invoice).not_to receive(:poll!)
      invoice = create(:invoice, :paid)
      Invoice.poll_unpaid!
    end

    it "should not call poll! on an expired invoice" do
      expect_any_instance_of(Invoice).not_to receive(:poll!)
      invoice = create(:invoice, :expired)
      Invoice.poll_unpaid!
    end
  end

  describe "self.email_unpaid_once!" do
    it "should call email! on every invoice that's unpaid and unsent" do
      latest_invoice.update status: 'unpaid', paid_at: nil
      expect_any_instance_of(Invoice).to receive(:email!).and_return true
      Invoice.email_unpaid_once!
    end

    it "should not email about a paid invoice" do
      latest_invoice.update status: 'paid', paid_at: Time.zone.local(2018, 02, 28)
      expect_any_instance_of(Invoice).not_to receive(:email!)
      Invoice.email_unpaid_once!
    end

    it "should not email about an invoice twice" do
      latest_invoice.update emailed_at: Time.zone.local(2018, 02, 28)
      expect_any_instance_of(Invoice).not_to receive(:email!)
      Invoice.email_unpaid_once!
    end

    it "should not email if a Lightning Charge ID is missing" do
      latest_invoice.update charge_invoice_id: nil
      expect_any_instance_of(Invoice).not_to receive(:email!)
      Invoice.email_unpaid_once!
    end
  end
end
