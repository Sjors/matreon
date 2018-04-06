class CreateContributions < ActiveRecord::Migration[5.1]
  def change
    create_table :contributions do |t|
      t.references :user, foreign_key: true
      t.bigint :amount

      t.timestamps
    end
  end
end
