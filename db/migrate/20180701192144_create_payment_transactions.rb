class CreatePaymentTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :payment_transactions do |t|
      t.json "payload", default: {}
      t.timestamps
    end
  end
end
