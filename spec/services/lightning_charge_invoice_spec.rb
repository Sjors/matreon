require 'rails_helper'

describe LightningChargeInvoice do
  context "when live", vcr: {record: :new_episodes} do
    before do
      described_class.stub(client_klass: LightningChargeClient)
    end

    it "creates and fetches invoice" do
      cached_invoice_id = "BCY_OtG1OGZZWlTubiQ0D"

      expect_any_instance_of(LightningChargeClient).to receive(:create_invoice).with(100).and_call_original

      lightning_charge_invoice = described_class.create(100)
      expect(lightning_charge_invoice.id).to eq(cached_invoice_id)
      expect(lightning_charge_invoice.status).to eq("unpaid")

      lightning_charge_invoice = described_class.find(cached_invoice_id)
      expect(lightning_charge_invoice.id).to eq(cached_invoice_id)
      expect(lightning_charge_invoice.status).to eq("unpaid")
    end
  end

  context "when mock" do
    before do
      described_class.stub(client_klass: LightningChargeMockClient)
      LightningChargeMockClient.reset!
    end

    it "creates and fetches invoice" do
      cached_invoice_id = "1"

      expect_any_instance_of(LightningChargeMockClient).to receive(:create_invoice).with(100).and_call_original

      lightning_charge_invoice = described_class.create(100)
      expect(lightning_charge_invoice.id).to eq(cached_invoice_id)
      expect(lightning_charge_invoice.status).to eq("unpaid")

      lightning_charge_invoice = described_class.find(cached_invoice_id)
      expect(lightning_charge_invoice.id).to eq(cached_invoice_id)
      expect(lightning_charge_invoice.status).to eq("unpaid")
    end
  end
end
