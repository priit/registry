class AddRegistrarForeignKeyToBillingSubscriptions < ActiveRecord::Migration
  def change
    add_foreign_key :billing_subscriptions, :registrars
  end
end
