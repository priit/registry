class CreateBillingSubscriptions < ActiveRecord::Migration
  def change
    create_table :billing_subscriptions do |t|
      t.integer :balance_threshold_cents, null: false
      t.integer :amount_cents, null: false
      t.belongs_to :registrar, index: true, null: false
    end
  end
end
