class LightningChargeMockClient
  @@last_id = 0
  @@invoices = {}

  def self.reset!
    @@last_id = 0
    @@invoices = {}
  end

  def fetch_invoice(invoice_id)
    @@invoices[invoice_id]
  end

  def create_invoice(amount)
    @@last_id += 1
    @@invoices[@@last_id.to_s] = {
      'id' => @@last_id.to_s,
      'amount' => amount,
      'status' => 'unpaid'
    }
  end
end
