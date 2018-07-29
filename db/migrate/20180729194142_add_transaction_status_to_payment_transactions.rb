class AddTransactionStatusToPaymentTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column :payment_transactions, :transaction_status, :string
  end
end
