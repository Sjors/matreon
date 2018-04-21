class AddBillingDayOfMonthToContributions < ActiveRecord::Migration[5.1]
  def change
    add_column :contributions, :billing_day_of_month, :int
  end
end
