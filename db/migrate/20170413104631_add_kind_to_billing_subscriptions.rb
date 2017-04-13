class AddKindToBillingSubscriptions < ActiveRecord::Migration
  def change
    add_column :billing_subscriptions, :kind, :string, array: true, default: []
  end
end
