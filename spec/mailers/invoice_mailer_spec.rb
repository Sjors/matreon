require "rails_helper"
 
RSpec.describe InvoiceMailer, :type => :mailer do
  describe "invoice" do
    let!(:invoice) do
      travel_to Time.zone.local(2018, 2, 1) do
        create(:invoice, :unpaid)
      end
    end

    let(:mail) { InvoiceMailer.with(invoice: invoice).new_invoice  }
 
    it "is sent to the sponsor" do
      expect(mail.to).to eq([invoice.user.email])
    end

    it "subject contains year and month" do
      expect(mail.subject).to include("2018-02")
    end

    it "body contains link to invoice page" do
       expect(mail.body.encoded).to include(invoice.url)
     end
  end
end
