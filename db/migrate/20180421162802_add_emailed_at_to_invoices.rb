class AddEmailedAtToInvoices < ActiveRecord::Migration[5.1]
  def change
    add_column :invoices, :emailed_at, :datetime
  end
end
