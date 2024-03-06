class CreateCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :customers, id: :uuid do |t|
      t.string :name
      t.string :email
      t.string :image_url

      t.timestamps
    end
  end
end
