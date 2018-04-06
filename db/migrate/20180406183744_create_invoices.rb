class CreateInvoices < ActiveRecord::Migration[5.1]
  def change
    create_table :invoices do |t|
      t.references :user, foreign_key: true
      t.bigint :amount
      t.datetime :paid_at
      t.string :charge_invoice_id
      t.datetime :polled_at
      t.string :status

      t.timestamps
    end
  end
end
