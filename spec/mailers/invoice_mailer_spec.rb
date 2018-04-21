require "rails_helper"
 
RSpec.describe InvoiceMailer, :type => :mailer do
  fixtures :invoices, :users

  describe "invoice" do
    let(:mail) { InvoiceMailer.with(invoice: invoices(:alice_february)).new_invoice  }
 
    it "is sent to the sponsor" do
      expect(mail.to).to eq(["alice@matreon.zz"])
    end

    it "subject contains year and month" do
      expect(mail.subject).to include("2018-02")
    end

    it "body contains link to invoice page" do
       expect(mail.body.encoded).to include(invoices(:alice_february).url)
     end
  end
end
