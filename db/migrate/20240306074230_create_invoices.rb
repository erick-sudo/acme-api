class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices, id: :uuid do |t|
      t.uuid :customer_id
      t.string :amount
      t.string :status

      t.timestamps
    end
  end
end
