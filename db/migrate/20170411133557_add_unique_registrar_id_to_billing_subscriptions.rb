class AddUniqueRegistrarIdToBillingSubscriptions < ActiveRecord::Migration
  def change
    remove_index :billing_subscriptions, :registrar_id
    add_index :billing_subscriptions, :registrar_id, unique: true
  end
end
